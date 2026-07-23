import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isInitialLoading = true;
  bool _isUploadingLogo = false;

  // Store controllers
  late TextEditingController _storeNameCtrl;
  late TextEditingController _storeTaglineCtrl;
  late TextEditingController _receiptHeaderCtrl;
  late TextEditingController _receiptFooterCtrl;

  // Profile controllers
  late TextEditingController _adminNameCtrl;
  late TextEditingController _adminEmailCtrl;

  // Password controllers
  late TextEditingController _currentPassCtrl;
  late TextEditingController _newPassCtrl;
  late TextEditingController _confirmPassCtrl;

  // Receipt Customization controllers
  late TextEditingController _storeAddressCtrl;
  late TextEditingController _storeContactCtrl;

  @override
  void initState() {
    super.initState();
    _storeNameCtrl = TextEditingController();
    _storeTaglineCtrl = TextEditingController();
    _receiptHeaderCtrl = TextEditingController();
    _receiptFooterCtrl = TextEditingController();
    _adminNameCtrl = TextEditingController();
    _adminEmailCtrl = TextEditingController();
    _currentPassCtrl = TextEditingController();
    _newPassCtrl = TextEditingController();
    _confirmPassCtrl = TextEditingController();
    _storeAddressCtrl = TextEditingController();
    _storeContactCtrl = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialSettingsData();
    });
  }

  @override
  void dispose() {
    _storeNameCtrl.dispose();
    _storeTaglineCtrl.dispose();
    _receiptHeaderCtrl.dispose();
    _receiptFooterCtrl.dispose();
    _adminNameCtrl.dispose();
    _adminEmailCtrl.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    _storeAddressCtrl.dispose();
    _storeContactCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInitialSettingsData() async {
    try {
      await ref.read(settingsProvider.notifier).loadSettings();
      final state = ref.read(settingsProvider);
      _storeNameCtrl.text = state.storeName;
      _storeTaglineCtrl.text = state.storeTagline;
      _receiptHeaderCtrl.text = state.receiptHeader;
      _receiptFooterCtrl.text = state.receiptFooter;
      _adminNameCtrl.text = state.adminName;
      _adminEmailCtrl.text = state.adminEmail;
      _storeAddressCtrl.text = state.storeAddress;
      _storeContactCtrl.text = state.storeContact;
    } catch (e) {
      _showErrorSnackBar('Failed to load settings: $e', null);
    } finally {
      if (mounted) {
        setState(() => _isInitialLoading = false);
      }
    }
  }

  void _showSuccessSnackBar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.successDark
            : AppColors.successLight,
      ),
    );
  }

  void _showErrorSnackBar(String msg, VoidCallback? retryAction) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.errorDark
            : AppColors.errorLight,
        action: retryAction != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: retryAction,
              )
            : null,
      ),
    );
  }

  Future<void> _pickAndUploadStoreLogo() async {
    if (_isUploadingLogo) return;
    setState(() => _isUploadingLogo = true);

    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (image != null) {
        final bytes = await image.readAsBytes();
        final client = SupabaseService.instance.client;
        final ext = image.name.split('.').last.toLowerCase();
        final storagePath = 'store_logo_${DateTime.now().millisecondsSinceEpoch}.$ext';

        String? publicUrl;
        try {
          try {
            await client.storage.from(SupabaseConstants.storageStoreAssets).uploadBinary(
                  storagePath,
                  bytes,
                  fileOptions: const sb.FileOptions(contentType: 'image/png'),
                );
            publicUrl = client.storage.from(SupabaseConstants.storageStoreAssets).getPublicUrl(storagePath);
          } catch (_) {
            // Fallback to menu-items
            await client.storage.from('menu-items').uploadBinary(
                  storagePath,
                  bytes,
                  fileOptions: const sb.FileOptions(contentType: 'image/png'),
                );
            publicUrl = client.storage.from('menu-items').getPublicUrl(storagePath);
          }
        } catch (_) {
          publicUrl = null;
        }

        if (publicUrl != null) {
          await ref.read(settingsProvider.notifier).updateStoreLogo(publicUrl);
          _showSuccessSnackBar('Store logo updated successfully.');
        } else {
          _showErrorSnackBar('Could not upload logo. Please check permissions.', _pickAndUploadStoreLogo);
        }
      }
    } catch (e) {
      _showErrorSnackBar('Upload error: $e', _pickAndUploadStoreLogo);
    } finally {
      if (mounted) {
        setState(() => _isUploadingLogo = false);
      }
    }
  }

  Future<void> _handleStoreSave() async {
    final notifier = ref.read(settingsProvider.notifier);
    try {
      if (_storeNameCtrl.text.trim().isEmpty) {
        _showErrorSnackBar('Store Name cannot be empty.', null);
        return;
      }
      await notifier.updateStoreName(_storeNameCtrl.text.trim());
      await notifier.saveSettings(
        storeTagline: _storeTaglineCtrl.text.trim(),
      );
      _showSuccessSnackBar('Store information updated.');
    } catch (e) {
      _showErrorSnackBar('Failed to save store info: $e', _handleStoreSave);
    }
  }

  Future<void> _handleReceiptSave() async {
    final notifier = ref.read(settingsProvider.notifier);
    try {
      await notifier.saveSettings(
        receiptHeader: _receiptHeaderCtrl.text.trim(),
        receiptFooter: _receiptFooterCtrl.text.trim(),
        storeAddress: _storeAddressCtrl.text.trim(),
        storeContact: _storeContactCtrl.text.trim(),
      );
      _showSuccessSnackBar('Receipt templates saved.');
    } catch (e) {
      _showErrorSnackBar('Failed to save receipt settings.', _handleReceiptSave);
    }
  }



  Future<void> _handleProfileSave() async {
    final notifier = ref.read(settingsProvider.notifier);
    try {
      if (_adminNameCtrl.text.trim().isEmpty || _adminEmailCtrl.text.trim().isEmpty) {
        _showErrorSnackBar('Name and Email are required.', null);
        return;
      }
      await notifier.updateAdminProfile(
        _adminNameCtrl.text.trim(),
        _adminEmailCtrl.text.trim(),
      );
      _showSuccessSnackBar('Admin profile details updated.');
    } catch (e) {
      _showErrorSnackBar('Failed to update admin profile: $e', _handleProfileSave);
    }
  }

  Future<void> _handlePasswordChange() async {
    if (_newPassCtrl.text.length < 6) {
      _showErrorSnackBar('Password must be at least 6 characters.', null);
      return;
    }
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      _showErrorSnackBar('New passwords do not match.', null);
      return;
    }

    final notifier = ref.read(settingsProvider.notifier);
    try {
      await notifier.changeAdminPassword(_newPassCtrl.text);
      _currentPassCtrl.clear();
      _newPassCtrl.clear();
      _confirmPassCtrl.clear();
      _showSuccessSnackBar('Password changed successfully.');
    } catch (e) {
      _showErrorSnackBar('Password update failed: $e', _handlePasswordChange);
    }
  }

  Future<void> _exportBackup() async {
    try {
      final jsonString = await ref.read(settingsProvider.notifier).exportBackupData();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/sukli_pos_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Sukli POS Data Backup',
      );
      _showSuccessSnackBar('Backup data exported.');
    } catch (e) {
      _showErrorSnackBar('Export failed: $e', _exportBackup);
    }
  }

  void _showRestoreDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : AppColors.backgroundLight,
          title: Text(
            'Restore from Backup',
            style: AppTextStyles.h3(context),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Paste the backup JSON content below or load from clipboard.',
                style: AppTextStyles.bodySecondary(context),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: textController,
                maxLines: 6,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.mediumBR,
                  ),
                  hintText: 'Paste backup JSON here...',
                  hintStyle: AppTextStyles.captionSecondary(context),
                ),
                style: AppTextStyles.caption(context),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      final data = await Clipboard.getData(Clipboard.kTextPlain);
                      if (data?.text != null) {
                        textController.text = data!.text!;
                      }
                    },
                    icon: const Icon(Icons.paste_rounded, size: 16),
                    label: const Text('Paste Clipboard'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final json = textController.text.trim();
                if (json.isEmpty) return;
                try {
                  Navigator.pop(ctx);
                  setState(() => _isInitialLoading = true);
                  await ref.read(settingsProvider.notifier).restoreBackupData(json);
                  _showSuccessSnackBar('Data successfully restored from backup.');
                } catch (e) {
                  _showErrorSnackBar('Restore failed: $e', null);
                } finally {
                  setState(() => _isInitialLoading = false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryLight,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumBR),
              ),
              child: const Text('Import Backup'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final dividerColor = textSecondary.withValues(alpha: 0.1);

    final state = ref.watch(settingsProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: textPrimary,
              size: 20,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.pop();
            },
          ),
          title: Text(
            'Settings',
            style: AppTextStyles.h2(context).copyWith(color: textPrimary),
          ),
        ),
        body: _isInitialLoading
            ? const ShimmerDetailsLoader()
            : RefreshIndicator(
                color: AppColors.secondaryLight,
                onRefresh: _loadInitialSettingsData,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  children: [
                    // SECTION 1: Store Information
                    _buildSectionHeader('Store Information', Icons.storefront_rounded),
                    AppCard(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          children: [
                            // Logo Upload
                            GestureDetector(
                              onTap: _pickAndUploadStoreLogo,
                              child: Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: card,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.secondaryLight.withValues(alpha: 0.3),
                                          width: 2,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: state.logoUrl != null
                                            ? CachedNetworkImage(
                                                imageUrl: state.logoUrl!,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) => const Center(
                                                  child: CircularProgressIndicator.adaptive(),
                                                ),
                                                errorWidget: (context, url, error) => const Icon(
                                                  Icons.store_rounded,
                                                  size: 40,
                                                  color: Colors.grey,
                                                ),
                                              )
                                            : Icon(
                                                Icons.store_rounded,
                                                size: 40,
                                                color: textSecondary,
                                              ),
                                      ),
                                    ),
                                    if (_isUploadingLogo)
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: CircularProgressIndicator(color: Colors.white),
                                        ),
                                      )
                                    else
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.secondaryLight,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: surface, width: 2),
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt_outlined,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AppTextField(
                              controller: _storeNameCtrl,
                              label: 'Store Name',
                              prefixIcon: Icon(Icons.business, color: textSecondary, size: 20),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppTextField(
                              controller: _storeTaglineCtrl,
                              label: 'Store Tagline',
                              prefixIcon: Icon(Icons.tag_faces_rounded, color: textSecondary, size: 20),
                            ),

                            const SizedBox(height: AppSpacing.md),
                            Align(
                              alignment: Alignment.centerRight,
                              child: AppPrimaryButton(
                                label: 'Save Store Info',
                                onPressed: _handleStoreSave,
                                width: 180,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.04, end: 0),
                    const SizedBox(height: AppSpacing.lg),

                    // SECTION 2: Receipt Customization
                    _buildSectionHeader('Receipt Customization', Icons.receipt_long_rounded),
                    AppCard(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          children: [
                            AppTextField(
                              controller: _receiptHeaderCtrl,
                              label: 'Receipt Header Text',
                              prefixIcon: Icon(Icons.title, color: textSecondary, size: 20),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppTextField(
                              controller: _storeAddressCtrl,
                              label: 'Store Address',
                              prefixIcon: Icon(Icons.location_on_rounded, color: textSecondary, size: 20),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppTextField(
                              controller: _storeContactCtrl,
                              label: 'Contact Number',
                              prefixIcon: Icon(Icons.phone_rounded, color: textSecondary, size: 20),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppTextField(
                              controller: _receiptFooterCtrl,
                              label: 'Receipt Footer Message',
                              prefixIcon: Icon(Icons.text_fields, color: textSecondary, size: 20),
                            ),
                            Divider(color: dividerColor),
                            SwitchListTile.adaptive(
                              title: Text('Print Store Logo', style: AppTextStyles.body(context).copyWith(color: textPrimary)),
                              subtitle: Text('Display logo at the top', style: AppTextStyles.captionSecondary(context)),
                              activeColor: AppColors.secondaryLight,
                              value: state.printLogo,
                              onChanged: (val) {
                                HapticFeedback.lightImpact();
                                ref.read(settingsProvider.notifier).saveSettings(printLogo: val);
                              },
                            ),
                            Divider(color: dividerColor),
                            SwitchListTile.adaptive(
                              title: Text('Show Date & Time', style: AppTextStyles.body(context).copyWith(color: textPrimary)),
                              subtitle: Text('Print transaction timestamp', style: AppTextStyles.captionSecondary(context)),
                              activeColor: AppColors.secondaryLight,
                              value: state.showDateTime,
                              onChanged: (val) {
                                HapticFeedback.lightImpact();
                                ref.read(settingsProvider.notifier).saveSettings(showDateTime: val);
                              },
                            ),
                            Divider(color: dividerColor),
                            SwitchListTile.adaptive(
                              title: Text('Show Cashier Name', style: AppTextStyles.body(context).copyWith(color: textPrimary)),
                              subtitle: Text('Print names on the billing slip', style: AppTextStyles.captionSecondary(context)),
                              activeColor: AppColors.secondaryLight,
                              value: state.showCashierName,
                              onChanged: (val) {
                                HapticFeedback.lightImpact();
                                ref.read(settingsProvider.notifier).saveSettings(showCashierName: val);
                              },
                            ),
                            Divider(color: dividerColor),
                            SwitchListTile.adaptive(
                              title: Text('Show Order Number', style: AppTextStyles.body(context).copyWith(color: textPrimary)),
                              subtitle: Text('Print short order identifiers', style: AppTextStyles.captionSecondary(context)),
                              activeColor: AppColors.secondaryLight,
                              value: state.showOrderNumber,
                              onChanged: (val) {
                                HapticFeedback.lightImpact();
                                ref.read(settingsProvider.notifier).saveSettings(showOrderNumber: val);
                              },
                            ),
                            Divider(color: dividerColor),
                             Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Printer Paper Size', style: AppTextStyles.body(context).copyWith(color: textPrimary)),
                                  Text('58mm (32 col) or 80mm (48 col) thermal paper', style: AppTextStyles.captionSecondary(context)),
                                  const SizedBox(height: AppSpacing.sm),
                                  SizedBox(
                                    width: double.infinity,
                                    child: SegmentedButton<String>(
                                      segments: const [
                                        ButtonSegment(value: '58mm', label: Text('58mm Roll')),
                                        ButtonSegment(value: '80mm', label: Text('80mm Roll')),
                                      ],
                                      selected: {state.paperSize},
                                      onSelectionChanged: (Set<String> newSelection) {
                                        HapticFeedback.selectionClick();
                                        ref.read(settingsProvider.notifier).saveSettings(paperSize: newSelection.first);
                                      },
                                      style: ButtonStyle(
                                        visualDensity: VisualDensity.compact,
                                        textStyle: WidgetStatePropertyAll(AppTextStyles.captionMedium(context)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(color: dividerColor),
                            SwitchListTile.adaptive(
                              title: Text('Auto-Cut Thermal Paper', style: AppTextStyles.body(context).copyWith(color: textPrimary)),
                              subtitle: Text('Send hardware cut command after printing', style: AppTextStyles.captionSecondary(context)),
                              activeColor: AppColors.secondaryLight,
                              value: state.autoCut,
                              onChanged: (val) {
                                HapticFeedback.lightImpact();
                                ref.read(settingsProvider.notifier).saveSettings(autoCut: val);
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Align(
                              alignment: Alignment.centerRight,
                              child: AppPrimaryButton(
                                label: 'Save Receipt Layout',
                                onPressed: _handleReceiptSave,
                                width: 200,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 50.ms, duration: 300.ms).slideY(begin: 0.04, end: 0),
                    const SizedBox(height: AppSpacing.lg),



                    // SECTION 5: Sync Settings
                    _buildSectionHeader('Sync Settings', Icons.cloud_sync_rounded),
                    AppCard(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          children: [
                            SwitchListTile.adaptive(
                              title: Text('Auto Sync Background', style: AppTextStyles.body(context).copyWith(color: textPrimary)),
                              subtitle: Text('Sync records when internet is online', style: AppTextStyles.captionSecondary(context)),
                              activeColor: AppColors.secondaryLight,
                              value: state.autoSync,
                              onChanged: (val) {
                                HapticFeedback.lightImpact();
                                ref.read(settingsProvider.notifier).saveSettings(autoSync: val);
                              },
                            ),
                            if (state.autoSync) ...[
                              Divider(color: dividerColor),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Sync Interval', style: AppTextStyles.body(context).copyWith(color: textPrimary)),
                                        Text('${state.syncInterval} seconds', style: AppTextStyles.bodyMedium(context).copyWith(color: AppColors.secondaryLight, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    Slider.adaptive(
                                      min: 15,
                                      max: 60,
                                      divisions: 3,
                                      activeColor: AppColors.secondaryLight,
                                      value: state.syncInterval.toDouble(),
                                      onChanged: (val) {
                                        HapticFeedback.selectionClick();
                                        ref.read(settingsProvider.notifier).saveSettings(syncInterval: val.toInt());
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                if (state.syncMessage != null)
                                  Expanded(
                                    child: Text(
                                      state.syncMessage!,
                                      style: AppTextStyles.captionSecondary(context),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                const SizedBox(width: AppSpacing.md),
                                AppPrimaryButton(
                                  label: 'Sync Now',
                                  isLoading: state.isSyncing,
                                  onPressed: () => ref.read(settingsProvider.notifier).syncNow(),
                                  width: 140,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 300.ms).slideY(begin: 0.04, end: 0),
                    const SizedBox(height: AppSpacing.lg),

                    // SECTION 6: Backup & Restore
                    _buildSectionHeader('Backup & Restore', Icons.backup_rounded),
                    AppCard(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          children: [
                            Text(
                              'Save all database transactions, categories, and inventory items to a secure JSON file. You can import it later to restore local operations.',
                              style: AppTextStyles.captionSecondary(context),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: AppSecondaryButton(
                                    label: 'Export Backup',
                                    icon: Icons.upload_rounded,
                                    onPressed: _exportBackup,
                                    textStyle: AppTextStyles.bodyMedium(context),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: AppPrimaryButton(
                                    label: 'Restore Backup',
                                    icon: Icons.download_rounded,
                                    onPressed: _showRestoreDialog,
                                    textStyle: AppTextStyles.bodyMedium(context),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 250.ms, duration: 300.ms).slideY(begin: 0.04, end: 0),
                    const SizedBox(height: AppSpacing.lg),

                    // SECTION 7: Admin Profile Settings
                    _buildSectionHeader('Admin Profile', Icons.admin_panel_settings_rounded),
                    AppCard(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          children: [
                            AppTextField(
                              controller: _adminNameCtrl,
                              label: 'Administrator Name',
                              prefixIcon: Icon(Icons.person, color: textSecondary, size: 20),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppTextField(
                              controller: _adminEmailCtrl,
                              label: 'Administrator Email',
                              prefixIcon: Icon(Icons.email, color: textSecondary, size: 20),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Align(
                              alignment: Alignment.centerRight,
                              child: AppPrimaryButton(
                                label: 'Update Profile Details',
                                onPressed: _handleProfileSave,
                                width: 220,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Divider(color: dividerColor, thickness: 1.5),
                            const SizedBox(height: AppSpacing.md),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Change Password',
                                style: AppTextStyles.bodyMedium(context).copyWith(color: textPrimary),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppTextField(
                              controller: _currentPassCtrl,
                              label: 'Current Password',
                              obscureText: true,
                              prefixIcon: Icon(Icons.lock_open, color: textSecondary, size: 20),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppTextField(
                              controller: _newPassCtrl,
                              label: 'New Password',
                              obscureText: true,
                              prefixIcon: Icon(Icons.lock_outline, color: textSecondary, size: 20),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppTextField(
                              controller: _confirmPassCtrl,
                              label: 'Confirm New Password',
                              obscureText: true,
                              prefixIcon: Icon(Icons.lock, color: textSecondary, size: 20),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Align(
                              alignment: Alignment.centerRight,
                              child: AppPrimaryButton(
                                label: 'Update Password',
                                onPressed: _handlePasswordChange,
                                width: 180,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 300.ms).slideY(begin: 0.04, end: 0),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.accentDark : AppColors.accentLight;

    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm, top: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.xs),
          Text(
            title,
            style: AppTextStyles.bodySemiBold(context).copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }


}
