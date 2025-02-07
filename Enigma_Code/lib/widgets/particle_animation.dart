import 'dart:math';
import 'package:flutter/material.dart';

class Particle {
  Offset position;
  Offset velocity;
  double age;
  double alpha;
  Particle({
    required this.position,
    required this.velocity,
    this.age = 0,
    this.alpha = 1.0,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    // Draw a black background
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.black);

    for (final p in particles) {
      paint.color = Colors.blue.withOpacity(p.alpha);
      canvas.drawCircle(p.position, 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return true;
  }
}

class ParticleAnimationWidget extends StatefulWidget {
  const ParticleAnimationWidget({super.key});

  @override
  State<ParticleAnimationWidget> createState() => _ParticleAnimationWidgetState();
}

class _ParticleAnimationWidgetState extends State<ParticleAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> particles = [];
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    // A controller that continuously ticks.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 100),
    )
      ..addListener(_updateParticles)
      ..repeat();
  }

  void _updateParticles() {
    setState(() {
      // Add new particles periodically.
      if (random.nextDouble() < 0.1) {
        particles.add(
          Particle(
            position: Offset(random.nextDouble() * MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height / 2),
            velocity: Offset((random.nextDouble() - 0.5) * 2, (random.nextDouble() - 0.5) * 2),
          ),
        );
      }
      // Update each particle.
      for (final p in particles) {
        p.position += p.velocity;
        p.age += 1;
        p.alpha = (1 - p.age / 100).clamp(0.0, 1.0);
      }
      // Remove dead particles.
      particles.removeWhere((p) => p.alpha <= 0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ParticlePainter(particles),
      child: Container(),
    );
  }
}
