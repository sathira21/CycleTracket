import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DailyLoggingScreen extends StatelessWidget {
  const DailyLoggingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Log', style: TextStyle(color: AppTheme.textDark)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
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
                _buildLogButton('Flow', Icons.water_drop),
                _buildLogButton('Symptoms', Icons.favorite),
                _buildLogButton('Mood', Icons.mood),
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
                      _buildPill('Light'), _buildPill('Medium'), _buildPill('Heavy'), _buildPill('Spot'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
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
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Saved Offline ✅', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    )
                  );
                },
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

  Widget _buildLogButton(String title, IconData icon) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          CircleAvatar(backgroundColor: AppTheme.primaryColor, radius: 25, child: Icon(icon, color: Colors.white)),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        ],
      ),
    );
  }

  Widget _buildPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.5)),
      ),
      child: Text(text, style: const TextStyle(color: AppTheme.textDark)),
    );
  }
}
