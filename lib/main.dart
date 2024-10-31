import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// The main application widget that builds a [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (icon) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color:
                      Colors.primaries[icon.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(icon, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// A widget representing a dock with draggable and reorderable [items].
class Dock<T extends Object> extends StatefulWidget {
  /// Creates a dock with specified items and item builder.
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial list of items in the dock.
  final List<T> items;

  /// Builder function to construct widgets for each item.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State for the [Dock] that manages draggable and reorderable items.
class _DockState<T extends Object> extends State<Dock<T>> {
  /// List of items that can be reordered in the dock.
  late final List<T> _items = widget.items.toList();

  int? _draggedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Draggable<T>(
            data: item,
            onDragStarted: () {
              setState(() {
                _draggedIndex = index; // Track the index of the dragged item
              });
            },
            onDraggableCanceled: (_, __) {
              setState(() {
                _draggedIndex = null; // Reset index if dragging is canceled
              });
            },
            onDragEnd: (_) {
              setState(() {
                _draggedIndex = null; // Clear dragged index on drag end
              });
            },
            feedback: Material(
              color: Colors.transparent,
              child: widget.builder(item),
            ),
            childWhenDragging: Container(
              height: 0,
              width: 0,
              color: Colors.transparent, // Make it transparent to keep space
            ),
            child: DragTarget<T>(
              onAcceptWithDetails: (receivedItem) {
                setState(() {
                  // Get the index of the item being dragged
                  final draggedItem = _items[_draggedIndex!];
                  // Remove the dragged item from the old position
                  _items.removeAt(_draggedIndex!);
                  // Insert it into the new position
                  _items.insert(index, draggedItem);
                  // Reset indices
                  _draggedIndex = null;
                });
              },
              onWillAcceptWithDetails: (receivedItem) => receivedItem != item,
              builder: (context, candidateData, rejectedData) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  transform: _draggedIndex == index
                      ? Matrix4.translationValues(0.0, -10.0, 0.0)
                      : Matrix4.identity(),
                  child: Opacity(
                    opacity: (_draggedIndex == index) ? 0.5 : 1.0,
                    child: widget.builder(item),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
