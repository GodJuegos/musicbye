// `math.pi` se usa para calcular una vuelta completa: pi * 2 = 360 grados.
// Si se elimina este import, el código del giro (`math.pi`) dejará de existir.
import 'dart:math' as math;

// Widgets visuales de Flutter: Scaffold, Text, Container, animaciones, etc.
import 'package:flutter/material.dart';

// Esta es la pantalla que se ve solo durante el arranque completo de MusicBye.
// Es Stateful porque el logo cambia de posición, giro y tamaño con el tiempo.
class StartupLoadingScreen extends StatefulWidget {
  const StartupLoadingScreen({super.key});

  @override
  State<StartupLoadingScreen> createState() => _StartupLoadingScreenState();
}

class _StartupLoadingScreenState extends State<StartupLoadingScreen>
    with SingleTickerProviderStateMixin {
  // Es el "reloj" de toda la animación. Todas las animaciones de abajo
  // avanzan sincronizadas usando este único controlador.
  late final AnimationController _animationController;

  // Cada variable representa una propiedad visual distinta del mismo logo.
  // Si se quita una de ellas, se debe quitar también su Transform en build().
  late final Animation<double> _jumpAnimation;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _scaleXAnimation;
  late final Animation<double> _scaleYAnimation;

  // Altura máxima del salto grande, usada para normalizar la sombra.
  // Debe ser parecida al valor negativo más grande del salto (ahora -70).
  // Si el salto se cambia a -100, conviene cambiar este valor a 100.
  static const double _maxJumpHeight = 68;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      // Un ciclo completo (dos saltos) dura 2.6 segundos.
      // Menos milisegundos = animación más rápida. Más = más lenta.
      duration: const Duration(milliseconds: 2600),
      // `repeat()` reinicia el ciclo al terminar. Si se elimina, se anima
      // solo una vez y luego el logo queda quieto.
    )..repeat();

    // ---------------------------------------------------------------------
    // SALTO (posición vertical)
    // Estructura: agacharse -> salto 1 -> aterrizaje/pausa -> agacharse ->
    // salto 2 (con giro) -> aterrizaje -> pausa final.
    // Los pesos son porcentajes del ciclo total (deben sumar 100).
    // ---------------------------------------------------------------------
    _jumpAnimation = TweenSequence<double>([
      // Agacharse antes del salto 1 (anticipación).
      // 0 es la altura normal; 6 baja 6 px porque en Flutter Y positivo baja.
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 6)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 6,
      ),
      // Salto 1 (pequeño) hacia arriba. -30 significa subir 30 px.
      // Un valor más negativo, por ejemplo -50, haría este salto más alto.
      TweenSequenceItem(
        tween: Tween<double>(begin: 6, end: -30)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 16,
      ),
      // Caída del salto 1: vuelve de -30 a 0, que es el suelo.
      TweenSequenceItem(
        tween: Tween<double>(begin: -30, end: 0)
            .chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 14,
      ),
      // Pausa/aterrizaje: aquí el ojo "confirma" que tocó el suelo
      TweenSequenceItem(
        tween: ConstantTween<double>(0),
        weight: 6,
      ),
      // Agacharse antes del salto 2 (anticipación, más marcada).
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 8)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 6,
      ),
      // Salto 2 (grande, con giro) hacia arriba.
      // -70 es la altura principal: hacerlo más negativo sube más el logo.
      TweenSequenceItem(
        tween: Tween<double>(begin: 8, end: -70)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 20,
      ),
      // Caída del salto 2: regresa al suelo mientras termina el giro.
      TweenSequenceItem(
        tween: Tween<double>(begin: -70, end: 0)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 20,
      ),
      // Pausa final antes de reiniciar el ciclo
      TweenSequenceItem(
        tween: ConstantTween<double>(0),
        weight: 12,
      ),
    ]).animate(_animationController);

    // ---------------------------------------------------------------------
    // ROTACIÓN: solo ocurre durante el salto 2 (subida + bajada),
    // que es cuando el logo está más tiempo en el aire.
    // Rango acumulado del salto 2: 48% -> 88% del ciclo.
    // ---------------------------------------------------------------------
    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(0),
        weight: 48,
      ),
      TweenSequenceItem(
        // El signo negativo cambia el sentido del giro. Si se quita el signo
        // menos, el logo girará hacia el lado contrario.
        tween: Tween<double>(begin: 0, end: -math.pi * 2)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0),
        weight: 12,
      ),
    ]).animate(_animationController);

    // ---------------------------------------------------------------------
    // SQUASH & STRETCH: le da peso físico a los saltos.
    // Se comprime al agacharse/aterrizar y se estira levemente en el aire.
    // ---------------------------------------------------------------------
    _scaleXAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.08), weight: 6),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 0.94), weight: 16),
      TweenSequenceItem(tween: Tween(begin: 0.94, end: 1.06), weight: 14),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 6),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.10), weight: 6),
      TweenSequenceItem(tween: Tween(begin: 1.10, end: 0.92), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.08), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 12),
    ]).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleYAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.90), weight: 6),
      TweenSequenceItem(tween: Tween(begin: 0.90, end: 1.06), weight: 16),
      TweenSequenceItem(tween: Tween(begin: 1.06, end: 0.94), weight: 14),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 6),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.88), weight: 6),
      TweenSequenceItem(tween: Tween(begin: 0.88, end: 1.08), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 0.92), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 12),
    ]).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    // Detiene y libera el reloj cuando esta pantalla desaparece. Si se omite,
    // la animación puede seguir usando recursos aunque ya estés en Biblioteca.
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Se usa para que la barra mida un porcentaje del ancho de cualquier móvil.
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            // X: -1 izquierda, 0 centro, 1 derecha.
            // Y: -1 arriba, 0 centro, 1 abajo.
            // Cambiar el segundo número hacia -1 sube la luz; hacia 1 la baja.
            center: Alignment(-0.65, -0.70),
            // Un radio mayor extiende la luz; uno menor la concentra.
            radius: 1.25,
            colors: [
              Color(0xFF2A1A12),
              Color(0xFF121212),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Grupo logo + sombra + texto, centrado como una sola unidad.
              // El texto queda pegado justo debajo de la sombra.
              Align(
                // Cambia -0.18 por -0.40 para subir todo el grupo.
                // Cámbialo por 0 para dejarlo exactamente en el centro.
                alignment: const Alignment(0, -0.18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      // Espacio disponible para que el logo salte sin chocar
                      // con el texto. Si se aumenta, hay más aire vertical.
                      height: 220,
                      child: Stack(
                        children: [
                          // Sombra en el "suelo": se achica y se desvanece
                          // cuando el logo sube. Esto es lo que hace leíble
                          // la altura del salto.
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 18),
                              child: AnimatedBuilder(
                                animation: _jumpAnimation,
                                builder: (context, _) {
                                  final liftAmount = (-_jumpAnimation.value)
                                          .clamp(0, _maxJumpHeight) /
                                      _maxJumpHeight;
                                  // Cuando el logo sube, la sombra se hace más
                                  // pequeña y tenue; esto hace visible el salto.
                                  final shadowScale =
                                      1.0 - (liftAmount * 0.5);
                                  final shadowOpacity =
                                      0.32 - (liftAmount * 0.22);

                                  return Opacity(
                                    opacity: shadowOpacity.clamp(0.0, 1.0),
                                    child: Transform.scale(
                                      scale: shadowScale,
                                      child: Container(
                                        width: 70,
                                        height: 14,
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(99),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              // Esta distancia separa el logo del suelo/sombra.
                              // Un valor mayor sube la posición de reposo.
                              padding: const EdgeInsets.only(bottom: 40),
                              child: AnimatedBuilder(
                                animation: _animationController,
                                child: Image.asset(
                                  'lib/loading_page/logo.png',
                                  // Mantener ancho y alto iguales evita deformar
                                  // el logo. Aumentar ambos lo hace más grande.
                                  width: 122,
                                  height: 122,
                                  fit: BoxFit.contain,
                                ),
                                builder: (context, child) {
                                  // El orden visual es: escala -> gira -> salta.
                                  // Si se elimina translate, ya no sube ni baja.
                                  return Transform.translate(
                                    offset: Offset(0, _jumpAnimation.value),
                                    // Si se elimina rotate, conserva los saltos
                                    // pero no realizará la vuelta completa.
                                    child: Transform.rotate(
                                      angle: _rotationAnimation.value,
                                      // Si se elimina scale, saltará y girará,
                                      // pero perderá el efecto de peso físico.
                                      child: Transform.scale(
                                        scaleX: _scaleXAnimation.value,
                                        scaleY: _scaleYAnimation.value,
                                        child: child,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Distancia entre la zona de salto y el nombre de la app.
                    // Un número mayor deja el texto más abajo respecto al logo.
                    const SizedBox(height: 20),
                    const Text(
                      'MusicBye',
                      style: TextStyle(
                        color: Color(0xFFFFF7F2),
                        // Cambiar este número modifica el tamaño del nombre.
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              // Barra de progreso: de vuelta pegada abajo, como estaba
              // antes de mover el texto.
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  // Más píxeles la suben; menos píxeles la acercan al borde.
                  padding: const EdgeInsets.only(bottom: 64),
                  child: SizedBox(
                    // 0.72 = 72% del ancho disponible. Cambiar a 0.90 la hará
                    // casi del ancho de pantalla; 0.50 la hará más corta.
                    width: screenWidth * 0.72,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      // No tiene `value`, por eso se mueve indefinidamente y
                      // representa una carga sin inventar porcentajes.
                      child: const LinearProgressIndicator(
                        minHeight: 8,
                        color: Color(0xFFFF5A1F),
                        backgroundColor: Color(0xFF383838),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
