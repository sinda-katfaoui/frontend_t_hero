import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class TestText extends StatelessWidget {
  const TestText({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Typography Test')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Headline Large', style: t.headlineLarge),
            const SizedBox(height: 8),
            Text('Headline Medium', style: t.headlineMedium),
            const SizedBox(height: 8),
            Text('Headline Small', style: t.headlineSmall),
            const Divider(height: 32),
            Text('Title Large', style: t.titleLarge),
            const SizedBox(height: 8),
            Text('Title Medium', style: t.titleMedium),
            const SizedBox(height: 8),
            Text('Title Small', style: t.titleSmall),
            const Divider(height: 32),
            Text('Body Large', style: t.bodyLarge),
            const SizedBox(height: 8),
            Text('Body Medium', style: t.bodyMedium),
            const SizedBox(height: 8),
            Text('Body Small', style: t.bodySmall),
            const Divider(height: 32),
            Text('Label Large', style: t.labelLarge),
            const SizedBox(height: 8),
            Text('Label Medium', style: t.labelMedium),
            const SizedBox(height: 8),
            Text('Label Small', style: t.labelSmall),
            const Divider(height: 32),
            const Text('T Hero brand color',
              style: TextStyle(
                color: TColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text('بطل تونس — Arabic text',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}