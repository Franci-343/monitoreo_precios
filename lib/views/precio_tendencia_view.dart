import 'package:flutter/material.dart';
import 'package:monitoreo_precios/models/precio_model.dart';
import 'package:monitoreo_precios/services/historial_service.dart';
import 'package:monitoreo_precios/services/alert_service.dart';
import 'dart:math';

class PrecioTendenciaView extends StatefulWidget {
  final int productoId;
  final String productoNombre;

  const PrecioTendenciaView({Key? key, required this.productoId, required this.productoNombre}) : super(key: key);

  @override
  State<PrecioTendenciaView> createState() => _PrecioTendenciaViewState();
}

class _PrecioTendenciaViewState extends State<PrecioTendenciaView> {
  List<Precio> _history = [];
  bool _loading = true;
  int _days = 7;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final h = await HistorialService.generateHistory(widget.productoId, days: _days);
    setState(() {
      _history = h;
      _loading = false;
    });
  }

  Future<void> _createAlertFromValue(double value) async {
    // Default create alert 'above' with value
    await AlertService.addAlert(widget.productoId, value, AlertDirection.above);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alerta creada (por encima)')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tendencia — ${widget.productoNombre}')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton<int>(
                        value: _days,
                        items: const [
                          DropdownMenuItem(value: 7, child: Text('Últimos 7 días')),
                          DropdownMenuItem(value: 14, child: Text('Últimos 14 días')),
                        ],
                        onChanged: (v) async {
                          if (v == null) return;
                          setState(() => _days = v);
                          await _load();
                        },
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (_history.isNotEmpty) {
                            final latest = _history.last.valor;
                            _createAlertFromValue(latest);
                          }
                        },
                        icon: const Icon(Icons.add_alert),
                        label: const Text('Crear alerta con último precio'),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: PriceChart(history: _history),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final p = _history[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_formatDateShort(p.fechaActualizacion)),
                                const SizedBox(height: 6),
                                Text('${p.valor.toStringAsFixed(2)} Bs', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
      ),
    );
  }
}

// Fecha simple en español (abreviada)
const List<String> _monthAbbr = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
String _formatDateShort(DateTime d) => '${d.day.toString().padLeft(2, '0')} ${_monthAbbr[d.month - 1]}';

class PriceChart extends StatelessWidget {
  final List<Precio> history;
  const PriceChart({Key? key, required this.history}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const Center(child: Text('Sin datos'));
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _PriceChartPainter(history),
        );
      }),
    );
  }
}

class _PriceChartPainter extends CustomPainter {
  final List<Precio> history;
  _PriceChartPainter(this.history);

  @override
  void paint(Canvas canvas, Size size) {
    final paintAxis = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;

    final padding = 24.0;
    final w = size.width - padding * 2;
    final h = size.height - padding * 2;

    // Draw axes
    final origin = Offset(padding, padding + h);
    final xEnd = Offset(padding + w, padding + h);
    canvas.drawLine(origin, xEnd, paintAxis);
    canvas.drawLine(origin, Offset(padding, padding), paintAxis);

    final values = history.map((e) => e.valor).toList();
    final minV = values.reduce(min);
    final maxV = values.reduce(max);
    final vRange = (maxV - minV) == 0 ? maxV : (maxV - minV);

    // Draw polyline
    final paintLine = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final dotPaint = Paint()..color = Colors.blue;

    final path = Path();
    for (int i = 0; i < history.length; i++) {
      final x = padding + (w * i / (history.length - 1));
      final y = padding + h - ((history[i].valor - minV) / vRange) * h;
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
      // draw dot
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
    canvas.drawPath(path, paintLine);

    // Draw y labels (min and max)
    final tpMax = TextPainter(text: TextSpan(text: maxV.toStringAsFixed(2), style: const TextStyle(color: Colors.black, fontSize: 12)), textDirection: TextDirection.ltr);
    tpMax.layout();
    tpMax.paint(canvas, Offset(2, padding - tpMax.height / 2));
    final tpMin = TextPainter(text: TextSpan(text: minV.toStringAsFixed(2), style: const TextStyle(color: Colors.black, fontSize: 12)), textDirection: TextDirection.ltr);
    tpMin.layout();
    tpMin.paint(canvas, Offset(2, padding + h - tpMin.height / 2));

    // Draw x labels (dates) - draw up to 5 labels
    final int maxLabels = 5;
    final step = max(1, (history.length / (maxLabels - 1)).floor());
    for (int i = 0; i < history.length; i += step) {
      final x = padding + (w * i / (history.length - 1));
      final date = _formatDateShort(history[i].fechaActualizacion);
      final tp = TextPainter(text: TextSpan(text: date, style: const TextStyle(color: Colors.black, fontSize: 10)), textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(x - tp.width / 2, padding + h + 4));
    }
  }

  @override
  bool shouldRepaint(covariant _PriceChartPainter oldDelegate) => oldDelegate.history != history;
}
