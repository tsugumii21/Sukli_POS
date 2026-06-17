import os

file_path = r'r:\Code\Sukli POS\sukli_pos\lib\features\auth\presentation\screens\cashier_profile_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace themeProvider import
content = content.replace("import '../../../../shared/providers/theme_provider.dart';", "")

# Replace themeMode and isDarkMode declarations
content = content.replace("final themeMode = ref.watch(themeProvider);\n", "")
content = content.replace("final isDarkMode = themeMode == ThemeMode.dark;\n", "")

# Remove the preferences section precisely
start_marker = "// -- Preferences ----------------------------------"
end_marker = ").animate().fadeIn(delay: 200.ms, duration: 320.ms),"

start_idx = content.find(start_marker)
end_idx = content.find(end_marker, start_idx)

if start_idx != -1 and end_idx != -1:
    content = content[:start_idx] + content[end_idx + len(end_marker):]
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Replaced successfully in cashier_profile_screen.dart")
else:
    print("Could not find markers")
