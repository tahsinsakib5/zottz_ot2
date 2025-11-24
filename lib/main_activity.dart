// main_activity.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:zottz_otone/exercise_config.dart';
import 'package:zottz_otone/firebase_service.dart';
import 'menu_selection_activity.dart';

class MainActivity extends StatefulWidget {
  final BluetoothDevice device;
  final ExerciseConfig config;
  final String username;

  const MainActivity({
    Key? key, 
    required this.device, 
    required this.config,
    required this.username,
  }) : super(key: key);

  @override
  _MainActivityState createState() => _MainActivityState();
}

class _MainActivityState extends State<MainActivity> {
  BluetoothCharacteristic? _txCharacteristic;
  BluetoothCharacteristic? _rxCharacteristic;
  bool _connected = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FirebaseService _firebaseService = FirebaseService();
  
  // Counters
  int _scissorCount = 0, _pencilCount = 0, _pincherCount = 0, _buttonCount = 0;
  int _totalTime = 0;
  DateTime? _sessionStartTime;
  Timer? _sessionTimer;
  
  // Repeat mode counters
  int _currentScissorCount = 0, _currentPencilCount = 0, 
      _currentPincherCount = 0, _currentButtonCount = 0;

  // Color and Music Maps
  final Map<String, String> _colorMap = {
    'RED': 'A', 'GREEN': 'B', 'BLUE': 'C', 'MAGENTA': 'D',
    'YELLOW': 'E', 'CYAN': 'F', 'YELLOW AND MAGENTA': 'G',
    'RED AND BLUE': 'H', 'BLUE AND RED': 'I', 'WHITE': 'J',
    'NO COLOR': 'K', 'RANDOM': 'L', 'CHANGING COLOR FORWARD': 'M',
    'CHANGING COLOR BACKWARD': 'N',
  };

  final Map<String, String> _musicMap = {
    'ABC MUSIC BOX': 'abc_music_box',
    'ABC SONG': 'abc_song',
    'Adventures': 'adventures',
    'AT THE FAIR': 'at_the_fair',
    'BAA BAA BLACK SHEEP': 'baa_baa_black_sheep',
    'BEACH': 'beach',
    'BENSOUND HAPPY ROCK': 'bensound_happyrock',
    'CARROUSEL': 'carrousel',
    'CIELO': 'cielo',
    'DIGITAL KID': 'digital_kid',
    'END OF SUMMER': 'end_of_summer',
    'HAPPY': 'happy',
    'HIGHWAY WILDFLOWERS': 'highway_wildflowers',
    'IF YOU HAPPY': 'if_you_happy',
    'JAMBALAYA': 'jambalaya',
    'JAZZ IN PARIS': 'jazz_in_paris',
    'LITTLE BOY': 'little_boy',
    'MY BONNIE': 'my_bonnie',
    'SPRING IN MY STEP': 'spring_in_my_step',
    'THE CREEK': 'the_creek',
    'TWINKLE TWINKLE LITTLE STAR': 'twinkle_little_star',
    'WATER LILLY': 'water_lily',
  };

  // Selected colors and music
  String _selectedScissorColor = 'RED';
  String _selectedPencilColor = 'GREEN'; 
  String _selectedPincherColor = 'BLUE';
  String _selectedButtonColor = 'MAGENTA';
  
  String _selectedScissorMusic = 'HAPPY';
  String _selectedPencilMusic = 'HAPPY';
  String _selectedPincherMusic = 'HAPPY';
  String _selectedButtonMusic = 'HAPPY';

  @override
  void initState() {
    super.initState();
    _connectToDevice();
    _startSessionTimer();
    
    // Initialize repeat counters
    _currentScissorCount = widget.config.counts.scissor;
    _currentPencilCount = widget.config.counts.pencil;
    _currentPincherCount = widget.config.counts.pincher;
    _currentButtonCount = widget.config.counts.button;
  }

  void _startSessionTimer() {
    _sessionStartTime = DateTime.now();
    _sessionTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _totalTime = DateTime.now().difference(_sessionStartTime!).inSeconds;
        });
      }
    });
  }

  Future<void> _connectToDevice() async {
    try {
      await widget.device.connect(autoConnect: false, timeout: Duration(seconds: 15));
      
      setState(() {
        _connected = true;
      });

      List<BluetoothService> services = await widget.device.discoverServices();
      
      for (BluetoothService service in services) {
        String serviceUuid = service.uuid.toString();
        print('Found service: $serviceUuid');
        
        if (serviceUuid.toLowerCase().contains('ffe0')) {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            String charUuid = characteristic.uuid.toString();
            print('Found characteristic: $charUuid');
            
            if (charUuid.toLowerCase().contains('ffe1')) {
              _txCharacteristic = characteristic;
              _rxCharacteristic = characteristic;
              
              // Enable notifications
              await _rxCharacteristic!.setNotifyValue(true);
              _rxCharacteristic!.onValueReceived.listen((value) {
                _handleData(value);
              });
              
              // Send initial command
              await _sendCommand('0');
              print('Connected and ready to receive data');
              break;
            }
          }
        }
      }

      if (_txCharacteristic == null) {
        print('HM-10 characteristic not found');
      }

    } catch (e) {
      print('Connection error: $e');
      setState(() {
        _connected = false;
      });
    }
  }

  void _handleData(List<int> data) {
    String dataString = String.fromCharCodes(data);
    print('Received data: $dataString');

    if (dataString.contains('scissor~') && widget.config.chkScissor) {
      _handleScissorPress();
    } else if (dataString.contains('pencil_1~') && widget.config.chkPencil) {
      _handlePencilPress();
    } else if (dataString.contains('pincher~') && widget.config.chkPincher) {
      _handlePincherPress();
    } else if (dataString.contains('button~') && widget.config.chkButton) {
      _handleButtonPress();
    }
  }

  void _handleScissorPress() {
    bool shouldPlayMusic = true;
    
    if (widget.config.repeatMode) {
      setState(() {
        _currentScissorCount--;
      });
      
      if (_currentScissorCount == 0) {
        shouldPlayMusic = true;
        _currentScissorCount = widget.config.mode == 6 ? 3 : 5;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scissor exercise completed!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        shouldPlayMusic = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Press Scissor $_currentScissorCount more times'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    if (!widget.config.repeatMode || shouldPlayMusic) {
      setState(() {
        _scissorCount++;
      });
      
      if (widget.config.musicScissor && shouldPlayMusic) {
        _playSound(_selectedScissorMusic);
      }
      
      _sendColorCommand(_selectedScissorColor);
      
      // Save to Firebase when exercise is completed in repeat mode or on each press in normal mode
      if (!widget.config.repeatMode) {
        _saveExerciseData();
      }
    }
  }

  void _handlePencilPress() {
    bool shouldPlayMusic = true;
    
    if (widget.config.repeatMode) {
      setState(() {
        _currentPencilCount--;
      });
      
      if (_currentPencilCount == 0) {
        shouldPlayMusic = true;
        _currentPencilCount = widget.config.mode == 6 ? 3 : 5;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pencil exercise completed!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        shouldPlayMusic = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Press Pencil $_currentPencilCount more times'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    if (!widget.config.repeatMode || shouldPlayMusic) {
      setState(() {
        _pencilCount++;
      });
      
      if (widget.config.musicPencil && shouldPlayMusic) {
        _playSound(_selectedPencilMusic);
      }
      
      _sendColorCommand(_selectedPencilColor);
      
      if (!widget.config.repeatMode) {
        _saveExerciseData();
      }
    }
  }

  void _handlePincherPress() {
    bool shouldPlayMusic = true;
    
    if (widget.config.repeatMode) {
      setState(() {
        _currentPincherCount--;
      });
      
      if (_currentPincherCount == 0) {
        shouldPlayMusic = true;
        _currentPincherCount = widget.config.mode == 6 ? 3 : 5;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pincher exercise completed!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        shouldPlayMusic = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Press Pincher $_currentPincherCount more times'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    if (!widget.config.repeatMode || shouldPlayMusic) {
      setState(() {
        _pincherCount++;
      });
      
      if (widget.config.musicPincher && shouldPlayMusic) {
        _playSound(_selectedPincherMusic);
      }
      
      _sendColorCommand(_selectedPincherColor);
      
      if (!widget.config.repeatMode) {
        _saveExerciseData();
      }
    }
  }

  void _handleButtonPress() {
    bool shouldPlayMusic = true;
    
    if (widget.config.repeatMode) {
      setState(() {
        _currentButtonCount--;
      });
      
      if (_currentButtonCount == 0) {
        shouldPlayMusic = true;
        _currentButtonCount = widget.config.mode == 6 ? 3 : 5;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Button exercise completed!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        shouldPlayMusic = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Press Button $_currentButtonCount more times'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    if (!widget.config.repeatMode || shouldPlayMusic) {
      setState(() {
        _buttonCount++;
      });
      
      if (widget.config.musicButton && shouldPlayMusic) {
        _playSound(_selectedButtonMusic);
      }
      
      _sendColorCommand(_selectedButtonColor);
      
      if (!widget.config.repeatMode) {
        _saveExerciseData();
      }
    }
  }

  Future<void> _playSound(String musicName) async {
    String? musicFile = _musicMap[musicName];
    if (musicFile != null) {
      try {
        if (_audioPlayer.state == PlayerState.playing) {
          await _audioPlayer.stop();
        }
        await _audioPlayer.play(AssetSource('sounds/$musicFile.mp3'));
      } catch (e) {
        print('Error playing sound: $e');
      }
    }
  }

  Future<void> _sendColorCommand(String colorName) async {
    if (widget.config.noLed) {
      await _sendCommand('K'); // No color
    } else {
      String? colorCode = _colorMap[colorName];
      if (colorCode != null) {
        await _sendCommand(colorCode);
      }
    }
  }

  Future<void> _sendCommand(String command) async {
    if (_txCharacteristic != null && _connected) {
      try {
        await _txCharacteristic!.write(command.codeUnits);
        print('Sent command: $command');
      } catch (e) {
        print('Error sending command: $e');
      }
    }
  }

  // Save exercise data to Firebase
  Future<void> _saveExerciseData() async {
    try {
      await _firebaseService.updateUserExerciseData(
        username: widget.username,
        scissorCount: _scissorCount,
        pencilCount: _pencilCount,
        pincherCount: _pincherCount,
        buttonCount: _buttonCount,
        timer: _totalTime,
      );
      
      print('Exercise data saved to Firebase');
    } catch (e) {
      print('Error saving exercise data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save exercise data'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleConnection() {
    if (_connected) {
      widget.device.disconnect();
      setState(() {
        _connected = false;
      });
    } else {
      _connectToDevice();
    }
  }

  void _goToMenu() {
    // Save data before going back to menu
    _saveExerciseData().then((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MenuSelectionActivity(
            device: widget.device,
            username: widget.username,
          ),
        ),
      );
    });
  }

  void _quitApp() {
    // Save final exercise data before quitting
    _saveExerciseData().then((_) {
      _sendCommand('1');
      widget.device.disconnect();
      Navigator.popUntil(context, (route) => route.isFirst);
    });
  }

  // Add a method to manually save data
  void _manualSave() {
    _saveExerciseData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exercise data saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Exercise - ${widget.config.modeName}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 4,
        shadowColor: Colors.blue.withOpacity(0.3),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: _connected ? Colors.green[400] : Colors.red[400],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: IconButton(
              icon: Icon(
                _connected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                color: Colors.white,
              ),
              onPressed: _toggleConnection,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.grey[100]!],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeaderSection(),
              SizedBox(height: 24),
              
              // Exercise Counters Grid
              Expanded(
                child: _buildCountersGrid(),
              ),
              
              // Progress Section (for repeat mode)
              if (widget.config.repeatMode) _buildProgressSection(),
              
              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _manualSave,
        child: Icon(Icons.save),
        tooltip: 'Save Exercise Data',
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Exercise Mode',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.config.modeName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _connected ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _connected ? Colors.green[200]! : Colors.red[200]!,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _connected ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      _connected ? 'Connected' : 'Disconnected',
                      style: TextStyle(
                        color: _connected ? Colors.green[800] : Colors.red[800],
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Divider(color: Colors.grey[300]),
          SizedBox(height: 8),
          Text(
            'Active Exercises:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (widget.config.chkScissor) _buildActiveExerciseChip('Scissor', Colors.blue),
              if (widget.config.chkPencil) _buildActiveExerciseChip('Pencil', Colors.green),
              if (widget.config.chkPincher) _buildActiveExerciseChip('Pincher', Colors.orange),
              if (widget.config.chkButton) _buildActiveExerciseChip('Button', Colors.purple),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'User: ${widget.username}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Session Time: ${_totalTime ~/ 60}:${(_totalTime % 60).toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveExerciseChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCountersGrid() {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      padding: EdgeInsets.symmetric(vertical: 8),
      children: [
        _counterWidget('Scissor', _scissorCount, 
                      widget.config.chkScissor ? Colors.blue : Colors.grey,
                      Icons.content_cut),
        _counterWidget('Pencil', _pencilCount, 
                      widget.config.chkPencil ? Colors.green : Colors.grey,
                      Icons.edit),
        _counterWidget('Pincher', _pincherCount, 
                      widget.config.chkPincher ? Colors.orange : Colors.grey,
                      Icons.thumb_up),
        _counterWidget('Button', _buttonCount, 
                      widget.config.chkButton ? Colors.purple : Colors.grey,
                      Icons.radio_button_checked),
      ],
    );
  }

  Widget _counterWidget(String label, int count, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: color,
                    height: 1.1,
                  ),
                ),
                Text(
                  'presses',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Remaining Counts',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (widget.config.chkScissor) 
                _progressItem('Scissor', _currentScissorCount, Colors.blue),
              if (widget.config.chkPencil) 
                _progressItem('Pencil', _currentPencilCount, Colors.green),
              if (widget.config.chkPincher) 
                _progressItem('Pincher', _currentPincherCount, Colors.orange),
              if (widget.config.chkButton) 
                _progressItem('Button', _currentButtonCount, Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _progressItem(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _goToMenu,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue[700],
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.blue[300]!),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back_ios_new, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Back to Menu',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _quitApp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.power_settings_new, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Quit',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _audioPlayer.dispose();
    widget.device.disconnect();
    super.dispose();
  }
}