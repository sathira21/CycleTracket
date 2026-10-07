import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/daily_log.dart';
import '../services/daily_log_store.dart';

class DailyLoggingScreen extends StatefulWidget {
  final DateTime? date;
  const DailyLoggingScreen({super.key, this.date});

  @override
  State<DailyLoggingScreen> createState() => _DailyLoggingScreenState();
}

class _DailyLoggingScreenState extends State<DailyLoggingScreen> {
  String _selectedFlow = '';
  String _selectedSymptoms = '';
  String _selectedMood = '';
  final TextEditingController _noteController = TextEditingController();

  late DateTime _logDate;

  @override
  void initState() {
    super.initState();
    _logDate = widget.date ?? DateTime.now();
    // Load existing log if any
    final existingLog = DailyLogStore.getLogForDate(_logDate);
    if (existingLog != null) {
      _selectedFlow = existingLog.flowIntensity;
      _selectedSymptoms = existingLog.symptoms;
      _selectedMood = existingLog.mood;
      _noteController.text = existingLog.note;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _saveLog() async {
    final log = DailyLog(
      date: _logDate,
      flowIntensity: _selectedFlow,
      symptoms: _selectedSymptoms,
      mood: _selectedMood,
      note: _noteController.text,
    );
    await DailyLogStore.saveLog(log);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saved Offline ✅', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        )
      );
    }
  }

  void _deleteLog() async {
    await DailyLogStore.deleteLog(_logDate);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Log Deleted 🗑️', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log for ${_logDate.day}/${_logDate.month}', style: const TextStyle(color: AppTheme.textDark)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _deleteLog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How are you feeling?', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLogCategory('Flow', Icons.water_drop, _selectedSymptoms == 'Flow' || _selectedMood == 'Flow' ? false : true, () {}),
                _buildLogCategory('Symptoms', Icons.favorite, false, () {}),
                _buildLogCategory('Mood', Icons.mood, false, () {}),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(border: Border.all(color: AppTheme.primaryColor.withOpacity(0.5)), borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('FLOW INTENSITY', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPill('Light'), 
                      _buildPill('Medium'), 
                      _buildPill('Heavy'), 
                      _buildPill('Spot'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'Add a note (optional)...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppTheme.primaryColor)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: AppTheme.primaryColor.withOpacity(0.5))),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveLog,
                child: const Text('Save Entry'),
              ),
            ),
            const SizedBox(height: 10),
            const Center(child: Text('🔒 Your data stays private & on-device', style: TextStyle(color: AppTheme.textLight))),
          ],
        ),
      ),
    );
  }

  Widget _buildLogCategory(String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.primaryColor : AppTheme.primaryColor.withOpacity(0.3), width: isSelected ? 2 : 1),
        ),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: isSelected ? AppTheme.primaryColor : Colors.grey.shade300, 
              radius: 25, 
              child: Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade600)
            ),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? AppTheme.primaryColor : AppTheme.textDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildPill(String text) {
    bool isSelected = _selectedFlow == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFlow = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.5)),
        ),
        child: Text(
          text, 
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          )
        ),
      ),
    );
  }
}
