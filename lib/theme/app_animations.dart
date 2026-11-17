import 'dart:math' as math;
import 'package:flutter/material.dart';

Route<T> rutaSuave<T>(Widget pagina) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 340),
    pageBuilder: (context, animation, secondaryAnimation) => pagina,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curva = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final desplazamiento = Tween<Offset>(
        begin: const Offset(0.0, 0.06),
        end: Offset.zero,
      ).animate(curva);
      final escala = Tween<double>(
        begin: 0.96,
        end: 1.0,
      ).animate(curva);

      return FadeTransition(
        opacity: curva,
        child: SlideTransition(
          position: desplazamiento,
          child: ScaleTransition(
            scale: escala,
            child: child,
          ),
        ),
      );
    },
  );
}

Route<T> rutaCerrarSesion<T>(Widget pagina) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 620),
    pageBuilder: (context, animation, secondaryAnimation) => pagina,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvaEntrada = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.15, 1.0, curve: Curves.easeOutBack),
      );
      final curvaOpacidad = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      );
      final subida = Tween<Offset>(
        begin: const Offset(0.0, 0.45),
        end: Offset.zero,
      ).animate(curvaEntrada);
      final escala = Tween<double>(
        begin: 0.90,
        end: 1.0,
      ).animate(curvaEntrada);

      return FadeTransition(
        opacity: curvaOpacidad,
        child: SlideTransition(
          position: subida,
          child: ScaleTransition(
            scale: escala,
            child: child,
          ),
        ),
      );
    },
  );
}

Route<T> rutaEntradaLoginAlFeed<T>(Widget pagina) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 680),
    pageBuilder: (context, animation, secondaryAnimation) => pagina,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final t = Curves.easeOutBack.transform(animation.value.clamp(0.0, 1.0));
          final opacidad = Curves.easeOut.transform(
            (animation.value * 1.4).clamp(0.0, 1.0),
          );
          final anguloX = (1.0 - t) * -0.26;
          final escala = 0.72 + (0.28 * t);
          final dy = (1.0 - t) * 70.0;

          final matriz = Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..translateByDouble(0.0, dy, 0.0, 1.0)
            ..rotateX(anguloX)
            ..scaleByDouble(escala, escala, 1.0, 1.0);

          return Opacity(
            opacity: opacidad,
            child: Transform(
              alignment: Alignment.center,
              transform: matriz,
              child: child,
            ),
          );
        },
      );
    },
  );
}

Route<T> rutaZoomPerfil<T>(Widget pagina) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 520),
    reverseTransitionDuration: const Duration(milliseconds: 540),
    pageBuilder: (context, animation, secondaryAnimation) => pagina,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final esRegreso = animation.status == AnimationStatus.reverse;

          if (!esRegreso) {
            final t = Curves.easeOutCubic.transform(animation.value);
            final escala = 0.08 + (0.92 * t);
            final radio = (1.0 - t) * 180.0;
            final opacidad = Curves.easeOut.transform(
              (animation.value * 1.6).clamp(0.0, 1.0),
            );

            return Opacity(
              opacity: opacidad,
              child: Transform.scale(
                scale: escala,
                alignment: const Alignment(0.86, -0.88),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radio),
                  child: child,
                ),
              ),
            );
          }

          final t = Curves.easeInCubic.transform(animation.value);
          final escala = 0.04 + (0.96 * t);
          final radio = (1.0 - t) * 44.0;
          final opacidad = Curves.easeIn.transform(
            (animation.value * 1.25).clamp(0.0, 1.0),
          );
          final inclinacion = (1.0 - t) * 0.14;

          final matriz = Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateX(inclinacion)
            ..scaleByDouble(escala, escala, 1.0, 1.0);

          return Opacity(
            opacity: opacidad,
            child: Transform(
              alignment: Alignment.center,
              transform: matriz,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radio),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45 * t),
                      blurRadius: 30 * (1.0 - t + 0.2),
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radio),
                  child: child,
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

class TransicionPaginaSuaveBuilder extends PageTransitionsBuilder {
  const TransicionPaginaSuaveBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curva = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final curvaSecundaria = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.12).animate(curvaSecundaria),
      alignment: const Alignment(0.82, -0.82),
      child: FadeTransition(
        opacity: curva,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0.0),
            end: Offset.zero,
          ).animate(curva),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.97, end: 1.0).animate(curva),
            child: child,
          ),
        ),
      ),
    );
  }
}

class ReboteAlPresionar extends StatefulWidget {
  final Widget child;
  final double escalaPresionado;
  final double escalaPop;

  const ReboteAlPresionar({
    super.key,
    required this.child,
    this.escalaPresionado = 0.92,
    this.escalaPop = 1.13,
  });

  @override
  State<ReboteAlPresionar> createState() => _ReboteAlPresionarState();
}

class _ReboteAlPresionarState extends State<ReboteAlPresionar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _escala;
  late final Animation<double> _giro;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _escala = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: widget.escalaPresionado)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 22,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: widget.escalaPresionado,
          end: widget.escalaPop,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 43,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: widget.escalaPop, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 35,
      ),
    ]).animate(_ctrl);

    _giro = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -0.025),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.025, end: 0.03),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.03, end: 0.0),
        weight: 35,
      ),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _alPresionar() {
    _ctrl.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _alPresionar(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return Transform.rotate(
            angle: _giro.value,
            child: Transform.scale(
              scale: _escala.value,
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

class BotonInscripcionCartoon extends StatefulWidget {
  final bool inscrito;
  final VoidCallback onPressed;

  const BotonInscripcionCartoon({
    super.key,
    required this.inscrito,
    required this.onPressed,
  });

  @override
  State<BotonInscripcionCartoon> createState() =>
      _BotonInscripcionCartoonState();
}

class _BotonInscripcionCartoonState extends State<BotonInscripcionCartoon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );
  }

  @override
  void didUpdateWidget(covariant BotonInscripcionCartoon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.inscrito != oldWidget.inscrito) {
      _ctrl.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toque() {
    _ctrl.forward(from: 0.0);
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final activo = widget.inscrito;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value;
        final onda = math.sin(t * math.pi);
        final escalaPico = activo ? 1.26 : 1.12;
        final escala = 1.0 + (escalaPico - 1.0) * math.sin(t * math.pi);
        final angulo = activo
            ? math.sin(t * math.pi * 3.0) * 0.11 * (1.0 - t)
            : math.sin(t * math.pi * 2.0) * 0.05 * (1.0 - t);
        final brillo = activo ? onda.clamp(0.0, 1.0) : 0.0;

        return Transform.rotate(
          angle: angulo,
          child: Transform.scale(
            scale: escala,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: (activo || brillo > 0.02)
                    ? [
                        BoxShadow(
                          color: esquema.primary
                              .withValues(alpha: 0.25 + brillo * 0.45),
                          blurRadius: 8 + 16 * brillo,
                          spreadRadius: 1 + 3 * brillo,
                        ),
                      ]
                    : null,
              ),
              child: OutlinedButton.icon(
                onPressed: _toque,
                style: OutlinedButton.styleFrom(
                  backgroundColor: activo
                      ? esquema.primary.withValues(alpha: 0.18 + brillo * 0.22)
                      : null,
                  foregroundColor: activo ? esquema.primary : null,
                  side: BorderSide(
                    color: activo
                        ? esquema.primary
                        : esquema.outline,
                    width: activo ? 2.0 : 1.2,
                  ),
                ),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 340),
                  transitionBuilder: (child, anim) {
                    return ScaleTransition(
                      scale: CurvedAnimation(
                        parent: anim,
                        curve: Curves.elasticOut,
                      ),
                      child: RotationTransition(
                        turns: Tween<double>(begin: 0.65, end: 1.0).animate(anim),
                        child: child,
                      ),
                    );
                  },
                  child: Icon(
                    activo ? Icons.check_circle_rounded : Icons.how_to_reg,
                    key: ValueKey<bool>(activo),
                    size: activo ? 20 : 18,
                    color: activo ? esquema.primary : null,
                  ),
                ),
                label: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  child: Text(
                    activo ? '¡Inscrito!' : 'Inscribirme',
                    key: ValueKey<bool>(activo),
                    style: TextStyle(
                      fontWeight: activo ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class BotonCancelarAnimado extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;

  const BotonCancelarAnimado({
    super.key,
    required this.child,
    required this.onPressed,
  });

  @override
  State<BotonCancelarAnimado> createState() => _BotonCancelarAnimadoState();
}

class _BotonCancelarAnimadoState extends State<BotonCancelarAnimado>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _corriendo = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _activar() async {
    if (_corriendo || widget.onPressed == null) return;
    _corriendo = true;
    await _ctrl.forward(from: 0.0);
    if (mounted) {
      _ctrl.value = 0.0;
      _corriendo = false;
      widget.onPressed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onPressed == null ? null : _activar,
      child: AbsorbPointer(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) {
            final t = _ctrl.value;
            final angulo = math.sin(t * math.pi * 4.0) * 0.13;
            final dx = math.sin(t * math.pi * 6.0) * 9.0 * (1.0 - t);
            final dy = math.sin(t * math.pi) * 4.0;
            final escala = 1.0 - math.sin(t * math.pi) * 0.1;
            final destello = math.sin(t * math.pi).clamp(0.0, 1.0);

            return Transform.translate(
              offset: Offset(dx, dy),
              child: Transform.rotate(
                angle: angulo,
                child: Transform.scale(
                  scale: escala,
                  child: DecoratedBox(
                    position: DecorationPosition.foreground,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.redAccent.withValues(alpha: destello * 0.25),
                      boxShadow: destello > 0.05
                          ? [
                              BoxShadow(
                                color: Colors.redAccent.withValues(alpha: destello * 0.45),
                                blurRadius: 14 * destello,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: child,
                  ),
                ),
              ),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

class EfectoErrorRojo extends StatefulWidget {
  final int disparador;
  final Widget child;
  final double radioBorde;

  const EfectoErrorRojo({
    super.key,
    required this.disparador,
    required this.child,
    this.radioBorde = 16,
  });

  @override
  State<EfectoErrorRojo> createState() => _EfectoErrorRojoState();
}

class _EfectoErrorRojoState extends State<EfectoErrorRojo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
    );
  }

  @override
  void didUpdateWidget(covariant EfectoErrorRojo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.disparador != oldWidget.disparador && widget.disparador > 0) {
      _ctrl.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final t = _ctrl.value;
        if (t == 0.0) return child!;
        final amortiguacion = 1.0 - t;
        final dx = math.sin(t * math.pi * 6.0) * 11.0 * amortiguacion;
        final rot = math.sin(t * math.pi * 4.0) * 0.018 * amortiguacion;
        final brillo = math.sin(t * math.pi).clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(dx, 0),
          child: Transform.rotate(
            angle: rot,
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.radioBorde),
                color: Colors.redAccent.withValues(alpha: brillo * 0.18),
                border: Border.all(
                  color: Colors.redAccent.withValues(alpha: brillo * 0.85),
                  width: 2.0 * brillo,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withValues(alpha: brillo * 0.5),
                    blurRadius: 24 * brillo,
                    spreadRadius: 2 * brillo,
                  ),
                ],
              ),
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

class EntradaSuave extends StatefulWidget {
  final Widget child;
  final int retrasoMs;
  final Offset offsetInicial;

  const EntradaSuave({
    super.key,
    required this.child,
    this.retrasoMs = 0,
    this.offsetInicial = const Offset(0, 0.08),
  });

  @override
  State<EntradaSuave> createState() => _EntradaSuaveState();
}

class _EntradaSuaveState extends State<EntradaSuave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacidad;
  late final Animation<Offset> _posicion;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    final curva = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _opacidad = Tween<double>(begin: 0.0, end: 1.0).animate(curva);
    _posicion = Tween<Offset>(
      begin: widget.offsetInicial,
      end: Offset.zero,
    ).animate(curva);

    if (widget.retrasoMs <= 0) {
      _ctrl.forward();
    } else {
      Future<void>.delayed(Duration(milliseconds: widget.retrasoMs), () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacidad,
      child: SlideTransition(
        position: _posicion,
        child: widget.child,
      ),
    );
  }
}
