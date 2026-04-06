import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../data/api_client.dart';
import '../../../../shared/models/app_media.dart';
import '../../../../shared/theme/agrorun_theme.dart';

class AccountHeroCard extends StatelessWidget {
  const AccountHeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            AgrorunPalette.forestDark,
            AgrorunPalette.forest,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(
              height: 1.5,
              color: Color(0xFFE6F0E7),
            ),
          ),
          const SizedBox(height: 22),
          child,
        ],
      ),
    );
  }
}

class AccountSectionCard extends StatelessWidget {
  const AccountSectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AgrorunPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              height: 1.5,
              color: AgrorunPalette.textMuted,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class ProfileAvatarEditor extends StatelessWidget {
  const ProfileAvatarEditor({
    super.key,
    required this.name,
    required this.onTap,
    this.media,
    this.localPreviewBytes,
    this.isUploading = false,
  });

  final String name;
  final VoidCallback onTap;
  final AppMedia? media;
  final Uint8List? localPreviewBytes;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isEmpty
        ? 'A'
        : name
            .trim()
            .split(RegExp(r'\s+'))
            .take(2)
            .map((part) => part.characters.first.toUpperCase())
            .join();

    ImageProvider<Object>? imageProvider;
    if (localPreviewBytes != null) {
      imageProvider = MemoryImage(localPreviewBytes!);
    } else if (media != null && media!.hasData) {
      imageProvider = NetworkImage(ApiClient().resolveMediaUrl(media!.url));
    }

    return Row(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFFE4F1E3),
              foregroundColor: AgrorunPalette.forest,
              backgroundImage: imageProvider,
              child: imageProvider == null
                  ? Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    )
                  : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFE6DDD1)),
                ),
                child: isUploading
                    ? const Padding(
                        padding: EdgeInsets.all(7),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AgrorunPalette.forest,
                        ),
                      )
                    : const Icon(
                        Icons.camera_alt_outlined,
                        size: 16,
                        color: AgrorunPalette.forest,
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Foto de perfil',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Usa una imagen clara para que tu cuenta se vea confiable y profesional.',
                style: TextStyle(
                  color: Color(0xFFDDE9DD),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: isUploading ? null : onTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFDBE8DD)),
                ),
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(isUploading ? 'Subiendo...' : 'Cambiar foto'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class InlineErrorCard extends StatelessWidget {
  const InlineErrorCard({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFEA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3B19F)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF8A2E1B),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class InfoPill extends StatelessWidget {
  const InfoPill({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F0E8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AgrorunPalette.forest),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class MediaThumb extends StatelessWidget {
  const MediaThumb({
    super.key,
    this.media,
    this.localBytes,
    this.onRemove,
    this.size = 84,
  });

  final AppMedia? media;
  final Uint8List? localBytes;
  final VoidCallback? onRemove;
  final double size;

  @override
  Widget build(BuildContext context) {
    ImageProvider<Object>? imageProvider;
    if (localBytes != null) {
      imageProvider = MemoryImage(localBytes!);
    } else if (media != null && media!.hasData) {
      imageProvider = NetworkImage(ApiClient().resolveMediaUrl(media!.url));
    }

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFFF3EEE4),
            borderRadius: BorderRadius.circular(18),
            image: imageProvider == null
                ? null
                : DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
          ),
          child: imageProvider == null
              ? const Icon(
                  Icons.photo_outlined,
                  color: AgrorunPalette.textMuted,
                )
              : null,
        ),
        if (onRemove != null)
          Positioned(
            top: 6,
            right: 6,
            child: InkWell(
              onTap: onRemove,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
