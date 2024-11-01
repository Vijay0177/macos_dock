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
  bool _isHovering = false; // Track if the dock is being hovered

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

          return AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            clipBehavior: Clip.antiAlias,
            child: Draggable<T>(
              data: item,
              onDragStarted: () {
                setState(() {
                  _draggedIndex = index; // Track the index of the dragged item
                  _isHovering = false; // Reset hover state when dragging starts
                });
              },
              onDraggableCanceled: (velocity, offset) {
                setState(() {
                  _draggedIndex = null; // Reset index if dragging is canceled
                  _isHovering = false; // Reset hover state
                });
              },
              onDragEnd: (details) {
                // If hovering, place the dragged item into the dock
                if (_isHovering) {
                  final draggedItem = item; // Store the item being dragged
                  setState(() {
                    // Remove the item from the original position
                    if (_draggedIndex != null) {
                      _items.removeAt(_draggedIndex!);
                    }
                    // Insert the dragged item at the hover index
                    _items.insert(index, draggedItem);
                    _isHovering = false; // Reset hover state
                    _draggedIndex = null; // Clear dragged index
                  });
                } else {
                  setState(() {
                    _draggedIndex = null; // Clear dragged index on drag end
                    _isHovering = false; // Reset hovering state
                  });
                }
              },
              feedback: Material(
                color: Colors.transparent,
                child: widget.builder(item),
              ),
              childWhenDragging: Container(
                height: 48,
                width: _isHovering ? 48 : 0,
                color: Colors.transparent, // Empty container during dragging
              ),
              child: DragTarget<T>(
                onWillAcceptWithDetails: (receivedItem) {
                  setState(() {
                    _isHovering = true; // Set hovering state to true
                  });
                  return true; // Accept the drag
                },
                onLeave: (receivedItem) {
                  setState(() {
                    _isHovering = false; // Reset hover state when leaving
                  });
                },
                onAcceptWithDetails: (receivedItem) {
                  // Logic handled in onDragEnd
                },
                builder: (context, candidateData, rejectedData) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Material(
                      color: Colors.transparent,
                      child: widget.builder(item),
                    ),
                  );
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
