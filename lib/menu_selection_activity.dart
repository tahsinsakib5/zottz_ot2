      import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:zottz_otone/exercise_config.dart';
import 'main_activity.dart';

class MenuSelectionActivity extends StatefulWidget {
  final String username;
  final BluetoothDevice device;

  const MenuSelectionActivity({Key? key, required this.username, required this.device}) : super(key: key);

  @override
  _MenuSelectionActivityState createState() => _MenuSelectionActivityState();
}

class _MenuSelectionActivityState extends State<MenuSelectionActivity> {
  String _selectedMenu = 'Select Exercise Mode';
  int? _selectedMenuIndex;

  ExerciseConfig _config = ExerciseConfig(
    counts: ExerciseCounts(
      scissor: 0,
      pencil: 0, 
      pincher: 0,
      button: 0,
    )
  );

  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'Buttons Only',
      'subtitle': 'Buttons activated',
      'icon': Icons.radio_button_checked,
      'color': Color(0xFF6366F1),
      'gradient': [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    },
    {
      'title': 'Pincher Only',
      'subtitle': 'Pincher activated',
      'icon': Icons.thumb_up,
      'color': Color(0xFFF59E0B),
      'gradient': [Color(0xFFF59E0B), Color(0xFFD97706)],
    },
    {
      'title': 'Pencils Only',
      'subtitle': 'Pencils activated',
      'icon': Icons.edit,
      'color': Color(0xFF10B981),
      'gradient': [Color(0xFF10B981), Color(0xFF059669)],
    },
    {
      'title': 'Scissors Only',
      'subtitle': 'Scissors activated',
      'icon': Icons.content_cut,
      'color': Color(0xFF3B82F6),
      'gradient': [Color(0xFF3B82F6), Color(0xFF2563EB)],
    },
    {
      'title': 'LED Only',
      'subtitle': 'Visual feedback only',
      'icon': Icons.lightbulb,
      'color': Color(0xFFF59E0B),
      'gradient': [Color(0xFFF59E0B), Color(0xFFEAB308)],
    },
    {
      'title': 'No LED',
      'subtitle': 'Audio feedback only',
      'icon': Icons.lightbulb_outline,
      'color': Color(0xFF6B7280),
      'gradient': [Color(0xFF6B7280), Color(0xFF4B5563)],
    },
    {
      'title': 'Repeat 3x',
      'subtitle': '3 repetitions each',
      'icon': Icons.repeat,
      'color': Color(0xFF06B6D4),
      'gradient': [Color(0xFF06B6D4), Color(0xFF0891B2)],
    },
    {
      'title': 'Repeat 5x',
      'subtitle': '5 repetitions each',
      'icon': Icons.repeat_one,
      'color': Color(0xFF8B5CF6),
      'gradient': [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            
            // Selection Status
            _buildSelectionStatus(),
            
            // Grid Menu
            Expanded(
              child: _buildMenuGrid(),
            ),
            
            // Start Button
            _buildStartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E40AF), Color(0xFF1D4ED8)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ZExerciser Pro',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Connected to ${widget.device.name ?? 'Device'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Choose Your Exercise Mode',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Select one mode to continue',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionStatus() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.fromLTRB(24, 20, 24, 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
        border: _selectedMenuIndex != null 
            ? Border.all(
                color: _menuItems[_selectedMenuIndex!]['color'].withOpacity(0.3),
                width: 2,
              )
            : Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _selectedMenuIndex != null 
                  ? _menuItems[_selectedMenuIndex!]['color'].withOpacity(0.1)
                  : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              _selectedMenuIndex != null ? Icons.check_circle : Icons.help_outline,
              color: _selectedMenuIndex != null 
                  ? _menuItems[_selectedMenuIndex!]['color']
                  : Colors.grey[400],
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedMenuIndex != null ? 'SELECTED MODE' : 'NO MODE SELECTED',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  _selectedMenu,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (_selectedMenuIndex != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _menuItems[_selectedMenuIndex!]['gradient'],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'READY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemCount: _menuItems.length,
        itemBuilder: (context, index) {
          return _buildMenuCard(index);
        },
      ),
    );
  }

  Widget _buildMenuCard(int index) {
    bool isSelected = _selectedMenuIndex == index;
    var item = _menuItems[index];

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isSelected 
            ? LinearGradient(
                colors: item['gradient'],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isSelected ? null : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isSelected 
                ? item['color'].withOpacity(0.4)
                : Colors.black12,
            blurRadius: isSelected ? 12 : 8,
            offset: Offset(0, isSelected ? 4 : 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleMenuSelection(index),
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background pattern for unselected cards
              if (!isSelected)
                Positioned(
                  right: -10,
                  top: -10,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: item['color'].withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Icon
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Colors.white.withOpacity(0.2)
                            : item['color'].withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item['icon'],
                        color: isSelected ? Colors.white : item['color'],
                        size: 20,
                      ),
                    ),
                    
                    // Text Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item['title'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.grey[800],
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            item['subtitle'],
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected ? Colors.white70 : Colors.grey[600],
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    
                    // Selection Indicator
                    if (isSelected)
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Selected',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _selectedMenuIndex != null ? _goToExercise : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedMenuIndex != null 
              ? Color(0xFF10B981) 
              : Colors.grey[400],
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: _selectedMenuIndex != null 
              ? Color(0xFF10B981).withOpacity(0.3)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_arrow_rounded,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'START EXERCISE',
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuSelection(int index) {
    setState(() {
      _selectedMenuIndex = index;
    });

    switch (index) {
      case 0:
        _setMenu0();
        break;
      case 1:
        _setMenu1();
        break;
      case 2:
        _setMenu2();
        break;
      case 3:
        _setMenu3();
        break;
      case 4:
        _setMenu4();
        break;
      case 5:
        _setMenu5();
        break;
      case 6:
        _setMenu6();
        break;
      case 7:
        _setMenu7();
        break;
    }
  }

  void _setMenu0() {
    setState(() {
      _selectedMenu = 'Buttons Only Mode';
      _config = ExerciseConfig(
        chkButton: true, 
        chkPencil: false, 
        chkPincher: false, 
        chkScissor: false,
        musicButton: true, 
        musicPencil: true, 
        musicPincher: true, 
        musicScissor: true,
        noLed: false, 
        repeatMode: false, 
        mode: 0, 
        modeName: 'Buttons only activated',
        counts: ExerciseCounts(button: 0, pencil: 0, pincher: 0, scissor: 0),
      );
    });
  }

  void _setMenu1() {
    setState(() {
      _selectedMenu = 'Pincher Only Mode';
      _config = ExerciseConfig(
        chkButton: false, 
        chkPencil: false, 
        chkPincher: true, 
        chkScissor: false,
        musicButton: true, 
        musicPencil: true, 
        musicPincher: true, 
        musicScissor: true,
        noLed: false, 
        repeatMode: false, 
        mode: 1, 
        modeName: 'Pincher only activated',
        counts: ExerciseCounts(button: 0, pencil: 0, pincher: 0, scissor: 0),
      );
    });
  }

  void _setMenu2() {
    setState(() {
      _selectedMenu = 'Pencils Only Mode';
      _config = ExerciseConfig(
        chkButton: false, 
        chkPencil: true, 
        chkPincher: false, 
        chkScissor: false,
        musicButton: true, 
        musicPencil: true, 
        musicPincher: true, 
        musicScissor: true,
        noLed: false, 
        repeatMode: false, 
        mode: 2, 
        modeName: 'Pencils only activated',
        counts: ExerciseCounts(button: 0, pencil: 0, pincher: 0, scissor: 0),
      );
    });
  }

  void _setMenu3() {
    setState(() {
      _selectedMenu = 'Scissors Only Mode';
      _config = ExerciseConfig(
        chkButton: false, 
        chkPencil: false, 
        chkPincher: false, 
        chkScissor: true,
        musicButton: true, 
        musicPencil: true, 
        musicPincher: true, 
        musicScissor: true,
        noLed: false, 
        repeatMode: false, 
        mode: 3, 
        modeName: 'Scissors only activated',
        counts: ExerciseCounts(button: 0, pencil: 0, pincher: 0, scissor: 0),
      );
    });
  }

  void _setMenu4() {
    setState(() {
      _selectedMenu = 'LED Only Mode';
      _config = ExerciseConfig(
        chkButton: true, 
        chkPencil: true, 
        chkPincher: true, 
        chkScissor: true,
        musicButton: false, 
        musicPencil: false, 
        musicPincher: false, 
        musicScissor: false,
        noLed: false, 
        repeatMode: false, 
        mode: 4, 
        modeName: 'Led Only',
        counts: ExerciseCounts(button: 0, pencil: 0, pincher: 0, scissor: 0),
      );
    });
  }

  void _setMenu5() {
    setState(() {
      _selectedMenu = 'No LED Mode';
      _config = ExerciseConfig(
        chkButton: true, 
        chkPencil: true, 
        chkPincher: true, 
        chkScissor: true,
        musicButton: true, 
        musicPencil: true, 
        musicPincher: true, 
        musicScissor: true,
        noLed: true, 
        repeatMode: false, 
        mode: 5, 
        modeName: 'No Led',
        counts: ExerciseCounts(button: 0, pencil: 0, pincher: 0, scissor: 0),
      );
    });
  }

  void _setMenu6() {
    setState(() {
      _selectedMenu = 'Repeat 3x Mode';
      _config = ExerciseConfig(
        chkButton: true, 
        chkPencil: true, 
        chkPincher: true, 
        chkScissor: true,
        musicButton: false, 
        musicPencil: false, 
        musicPincher: false, 
        musicScissor: false,
        noLed: false, 
        repeatMode: true, 
        mode: 6, 
        modeName: 'Repeat 3x',
        counts: ExerciseCounts(button: 3, pencil: 3, pincher: 3, scissor: 3),
      );
    });
  }

  void _setMenu7() {
    setState(() {
      _selectedMenu = 'Repeat 5x Mode';
      _config = ExerciseConfig(
        chkButton: true, 
        chkPencil: true, 
        chkPincher: true, 
        chkScissor: true,
        musicButton: false, 
        musicPencil: false, 
        musicPincher: false, 
        musicScissor: false,
        noLed: false, 
        repeatMode: true, 
        mode: 7, 
        modeName: 'Repeat 5x',
        counts: ExerciseCounts(button: 5, pencil: 5, pincher: 5, scissor: 5),
      );
    });
  }

  void _goToExercise() {
    if (_selectedMenuIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an exercise mode first'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainActivity(
          device: widget.device, 
          config: _config, username:widget.username,
        ),
      ),
    );
  }
}