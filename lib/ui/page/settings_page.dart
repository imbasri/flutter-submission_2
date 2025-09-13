import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/theme_provider.dart';
import '../../provider/reminder_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pengaturan',
          style: TextStyle(
            fontFamily: 'OrangeJuice',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer2<ThemeProvider, ReminderProvider>(
        builder: (context, themeProvider, reminderProvider, child) {
          if (!themeProvider.isInitialized || !reminderProvider.isInitialized) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.palette,
                              color: Theme.of(context).primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Tema Aplikasi',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Lato',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Pilih tema yang sesuai dengan preferensi Anda',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        _buildThemeOption(
                          context: context,
                          themeProvider: themeProvider,
                          title: 'Tema Terang',
                          subtitle: 'Tampilan dengan latar belakang terang',
                          icon: Icons.light_mode,
                          isSelected: !themeProvider.isDarkMode,
                          onTap: () => themeProvider.setDarkMode(false),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        _buildThemeOption(
                          context: context,
                          themeProvider: themeProvider,
                          title: 'Tema Gelap',
                          subtitle: 'Tampilan dengan latar belakang gelap',
                          icon: Icons.dark_mode,
                          isSelected: themeProvider.isDarkMode,
                          onTap: () => themeProvider.setDarkMode(true),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tema saat ini: ${themeProvider.currentThemeName}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.swap_horiz,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: const Text(
                      'Toggle Tema',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Lato',
                      ),
                    ),
                    subtitle: const Text('Beralih tema dengan cepat'),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    onTap: () {
                      themeProvider.toggleTheme();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Tema berubah ke ${themeProvider.isDarkMode ? "Gelap" : "Terang"}',
                          ),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 30),
                
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.alarm,
                              color: Theme.of(context).primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Daily Reminder',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Lato',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Terima notifikasi pengingat makan siang setiap hari pada waktu yang ditentukan',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: reminderProvider.isReminderEnabled 
                                  ? Theme.of(context).primaryColor 
                                  : Theme.of(context).dividerColor,
                              width: reminderProvider.isReminderEnabled ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SwitchListTile(
                            secondary: Icon(
                              reminderProvider.isReminderEnabled 
                                  ? Icons.notifications_active 
                                  : Icons.notifications_off,
                              color: reminderProvider.isReminderEnabled 
                                  ? Theme.of(context).primaryColor 
                                  : Theme.of(context).iconTheme.color,
                            ),
                            title: Text(
                              'Pengingat Harian',
                              style: TextStyle(
                                fontWeight: reminderProvider.isReminderEnabled 
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                                fontFamily: 'Lato',
                              ),
                            ),
                            subtitle: Text(reminderProvider.reminderStatusText),
                            value: reminderProvider.isReminderEnabled,
                            onChanged: (bool value) async {
                              await reminderProvider.setReminderEnabled(value);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      value 
                                          ? 'Daily reminder diaktifkan! Notifikasi akan muncul setiap hari pukul ${reminderProvider.reminderTimeText}' 
                                          : 'Daily reminder dinonaktifkan',
                                    ),
                                    duration: const Duration(seconds: 3),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                if (reminderProvider.isReminderEnabled) ...[
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.access_time,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: const Text(
                        'Waktu Pengingat',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Lato',
                        ),
                      ),
                      subtitle: Text('Pukul ${reminderProvider.reminderTimeText}'),
                      trailing: Icon(
                        Icons.edit,
                        size: 16,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: reminderProvider.reminderTime,
                          builder: (BuildContext context, Widget? child) {
                            return MediaQuery(
                              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                              child: child!,
                            );
                          },
                        );
                        
                        if (picked != null && mounted) {
                          await reminderProvider.setReminderTime(picked);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Waktu pengingat diubah ke ${reminderProvider.reminderTimeText}'),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: Theme.of(context).primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pengingat Berikutnya',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  reminderProvider.nextReminderText,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
                
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.notifications_active,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: const Text(
                      'Test Notifikasi',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Lato',
                      ),
                    ),
                    subtitle: const Text('Kirim notifikasi test untuk memastikan fitur berfungsi'),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    onTap: () async {
                      await reminderProvider.testNotification();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Test notifikasi dikirim!'),
                            duration: Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required ThemeProvider themeProvider,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected 
              ? Theme.of(context).primaryColor 
              : Theme.of(context).dividerColor,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected 
              ? Theme.of(context).primaryColor 
              : Theme.of(context).iconTheme.color,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'Lato',
          ),
        ),
        subtitle: Text(subtitle),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
              )
            : const Icon(Icons.radio_button_unchecked),
        onTap: onTap,
      ),
    );
  }
}
