import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          if (!themeProvider.isInitialized) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Theme Section
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
                        
                        // Light Theme Option
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
                        
                        // Dark Theme Option
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
                
                // Current Theme Info
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
                
                // Quick Toggle
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
