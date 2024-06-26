# Seguir instrucciones para agregar soporte a godot v3
@tool  # <- Comentar   @tool para godot v3
# tool # <- Descomentar tool para godot v3
extends EditorPlugin

const GRAPH_EDITOR_PATH : String = \
	"res://addons/object_state_machine/support_editor_godot_v{major}/graph_state_machine.tscn"

var _graph_editor_path : String
# guarda instancia del GraphEditor
var _graph_editor         : Node
var _graph_editor_init    : bool
# guarda el boton que se asignara al editor de godot
var _graph_editor_button  : Button

var _godot_version : int

# guarda el objeto seleccionado
var _object_ref : NodeStateMachine

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	self._godot_version = Engine.get_version_info().major
	self._graph_editor_path = GRAPH_EDITOR_PATH.format(
																		{"major": _godot_version})

	if not ResourceLoader.exists(self._graph_editor_path):
		return

	self._graph_editor_init = true
	if self._godot_version < 4:
		self._graph_editor = load(self._graph_editor_path).instance()
	else:
		self._graph_editor = load(self._graph_editor_path).instantiate()
	self._graph_editor_button = add_control_to_bottom_panel(
									self._graph_editor, "State Machine")
	self._make_visible(false)


func _exit_tree() -> void:
	if self._graph_editor_init:
		self._graph_editor_button.queue_free()
		remove_control_from_bottom_panel(self._graph_editor)

	self._graph_editor_init = false

# add support virtual Godot v3
func handles(object : Object) -> bool:
	return self._handles(object)

# valida el objeto que seleccionaron desde el arbol de nodos
func _handles(object: Object) -> bool:
	# desde remote, opcion de depuración todos los objetos llegan
	# con esta clase EditorDebuggerRemoteObject
	# fix error al seleccionar en el inspector
	#  Invalid call. Nonexistent function 'is_class_state_machine'
	#  in base 'ScriptEditorDebuggerInspectedObject ( godot v3)
	#  in base 'EditorDebuggerRemoteObject          ( godot v4)
	var _editor_debugger_inspected_object : String = "EditorDebuggerRemoteObject"
	if _godot_version < 4:
		_editor_debugger_inspected_object = "ScriptEditorDebuggerInspectedObject"

	return (object is NodeStateMachine) and \
		object.get_class() != _editor_debugger_inspected_object

# add support virtual Godot v3
func make_visible(visible: bool) -> void:
	self._make_visible(visible)

# Se ejecuta luego de _handles para alida cuando es visible
# el tab (State Machine) en el editor de godot
func _make_visible(visible: bool) -> void:
	if not visible:
		hide_bottom_panel()
	self._graph_editor_button.visible = visible

# add support virtual Godot v3
func edit(object: Object) -> void:
	self._edit(object)

# _edit se llama cuando se selecciona o se cambia de seleccion en el arbol
# de nodos del editor
func _edit(object: Object) -> void:
	self._graph_editor.set_state_machine(object)
	# aqui validamos si perdimos el focus del objeto seleccionado previamente
	if object == self._object_ref:
		hide_bottom_panel()
		self._object_ref = null
		self._graph_editor.set_state_machine(self._object_ref)
		return
