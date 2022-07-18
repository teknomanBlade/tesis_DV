using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

public class NodeDisplayWindow : EditorWindow
{
    private List<FilterNode> _allNodes;
    private List<FilterNode> _allConnected;
    private FilterNode _selectedNode;

    private Vector2 _originalMousePosition;
    private Vector2 _prevPan;

    //para el paneo
    private bool _panningScreen;
    private Rect _graphRect;
    private float _graphRectXMin = -100000;
    private float _graphRectXMax = 1000000;
    private float _graphRectYMin = -100000;
    private float _graphRectYMax = 1000000;

    public void SetInitialStates()
    {
        _allNodes = new List<FilterNode>();

        _graphRect = new Rect(_graphRectXMin / 2, _graphRectYMin / 2, _graphRectXMax / 2, _graphRectYMax / 2);
    }

    private void OnGUI()
    {
        /*chequeamos los eventos de mouse. 
        pedir el Event.current desde adentro de la misma funcion puede traer problemas 
        (es el evento que esta ocurriendo "ahora")
        por lo que para estar seguros que nos funciona bien siempre tomamos el de OnGUI y se lo mandamos como parámetro
        */
        CheckMouseInput(Event.current);

        //utilizamos el BeginGroup para que tome todo lo que dibujamos adentro como un grupo único, lo que nos va a permitir panear el grafo.
        GUI.BeginGroup(_graphRect);
        /*
         BeginWindows();
         //Habilita la opcion de que aca adentro se puedan crear "ventanas intermedias" o "ventanas dentro de ventanas".
         por lo tanto, aca adentro vamos a dibujar los nodos.
         EndWindows();
         */
        BeginWindows();
        var oriCol = GUI.backgroundColor;
        for (int i = 0; i < _allNodes.Count; i++)
        {
            foreach (var c in _allNodes[i].connected)
            {
                Handles.color = Color.green;
                Handles.DrawLine(
                new Vector2(_allNodes[i].myRect.position.x + _allNodes[i].myRect.width / 2f,
                            _allNodes[i].myRect.position.y + _allNodes[i].myRect.height / 2f),
                new Vector2(c.myRect.position.x + c.myRect.width / 2f,
                            c.myRect.position.y + c.myRect.height / 2f), 0.25f);

            }
        }

        for (int i = 0; i < _allNodes.Count; i++)
        {
            if (_allNodes[i] == _selectedNode)
                GUI.backgroundColor = Color.green;

            //Dibujo el nodo con GUI.Window
            //Guardo el rect para saber donde esta dibujado
            _allNodes[i].myRect = GUI.Window(i, _allNodes[i].myRect, DrawNode, _allNodes[i].nodeName);
            GUI.backgroundColor = oriCol;
        }

        EndWindows();
        GUI.EndGroup();
    }

    private void CheckMouseInput(Event currentE)
    {
        if (!mouseOverWindow)  //Asi puedo dejar de panear fuera de la ventana
            _panningScreen = false;

        if (!_graphRect.Contains(currentE.mousePosition) || !(focusedWindow == this || mouseOverWindow == this))
            return;

        //Paneo
        if (currentE.button == 2 && currentE.type == EventType.MouseDown)
        {
            _panningScreen = true;
            _prevPan = new Vector2(_graphRect.x, _graphRect.y);
            _originalMousePosition = currentE.mousePosition;
        }
        else if (currentE.button == 2 && currentE.type == EventType.MouseUp)
            _panningScreen = false;

        if (_panningScreen)
        {
            //Asigno los nuevos valores al Rect del graphPan
            var newX = _prevPan.x + currentE.mousePosition.x - _originalMousePosition.x;
            newX = newX < _graphRectXMin ? _graphRectXMin : newX;
            newX = newX + _graphRect.width > _graphRectXMax ? _graphRectXMax - _graphRect.width : newX;
            _graphRect.x = newX;

            var newY = _prevPan.y + currentE.mousePosition.y - _originalMousePosition.y;
            newY = newY < _graphRectYMin ? _graphRectYMin : newY;
            newY = newY + _graphRect.height > _graphRectYMax ? _graphRectYMax - _graphRect.height : newY;
            _graphRect.y = newY;

            Repaint();
        }

        //abre el menu contextual
        /*if (currentE.button == 1 && currentE.type == EventType.MouseDown)
            ContextMenuOpen();*/

        //selecciono el nodo
        FilterNode overNode = null;
        for (int i = 0; i < _allNodes.Count; i++)
        {
            _allNodes[i].CheckMouse(Event.current, new Vector2(_graphRect.x, _graphRect.y));
            if (_allNodes[i].OverNode)
                overNode = _allNodes[i];
        }

        var prevSel = _selectedNode;
        if (currentE.button == 0 && currentE.type == EventType.MouseDown)
        {
            if (overNode != null)
                _selectedNode = overNode;
            else
                _selectedNode = null;

            if (prevSel != _selectedNode)
                Repaint();
        }
    }
    /*
    #region CONTEXT MENU
    private void ContextMenuOpen()
    {
        //Creo un menu desplegable
        GenericMenu menu = new GenericMenu();
        //Creo nuevos items, puedo asociarlos a funciones
        menu.AddItem(new GUIContent("Connect Node"), false, PrimerItem);
        menu.AddItem(new GUIContent("Disconnect Node"), false, PrimerItem);
        //Lo muestro
        menu.ShowAsContext();
    }

    private void PrimerItem()
    {
        Debug.Log("no hago nada");
    }
    #endregion
    */
    public void AddNode(string nodeName)
    {
        //Para evitar crear mas de un nodo con el mismo nombre
        _allNodes.ForEach(x => { if(x.nodeName == nodeName) return; });
        _allNodes.Add(new FilterNode(Mathf.Abs(_graphRectXMin) / 2 - (Mathf.Abs(_graphRectXMin) / 2 - Mathf.Abs(_graphRect.x)),
                                   Mathf.Abs(_graphRectYMin) / 2 - (Mathf.Abs(_graphRectYMin) / 2 - Mathf.Abs(_graphRect.y)),
                                   200, 150, nodeName));
        Repaint();
    }

    private void DrawNode(int id)
    {
        //le dibujamos lo que queramos al nodo...
        EditorGUILayout.BeginHorizontal();
        //EditorGUILayout.LabelField("Dialogo", GUILayout.Width(100));

        //_allNodes[id].dialogo = EditorGUILayout.TextField(_allNodes[id].dialogo, GUILayout.Height(50));
        EditorGUILayout.EndHorizontal();
        //_allNodes[id].duration = EditorGUILayout.FloatField("Duration", _allNodes[id].duration);
        _allNodes[id].nodeToInteractName = EditorGUILayout.TextField("Nodo:", _allNodes[id].nodeToInteractName);

        var n = _allNodes[id].nodeToInteractName;

        //Conecto un nodo
        if (n != "" && _allNodes[id].nodeName != n)
        {
            if (GUILayout.Button("Connect"))
            {
                ConnectNode(id, n);
            }
        }
        //Desconecto un nodo
        if (n != "" && _allNodes[id].nodeName != n)
        {
            if (GUILayout.Button("Disconnect"))
            {
                DisconnectNode(id, n);
            }
        }

        //Si no estamos paneando todos los nodos
        //Arrastramos un nodo en particular
        if (!_panningScreen)
        {
            //esto habilita el arrastre del nodo.
            //pasandole como parámetro un Rect podemos setear que la zona "agarrable" a una específica.
            GUI.DragWindow();

            if (!_allNodes[id].OverNode) return;

            //clampeamos los valores para asegurarnos que no se puede arrastrar el nodo por fuera del 
            //"área" que nosotros podemos panear

            _allNodes[id].myRect.x = Mathf.Clamp(_allNodes[id].myRect.x, _graphRectXMin / 2, _graphRectXMax / 2);
            _allNodes[id].myRect.y = Mathf.Clamp(_allNodes[id].myRect.y, _graphRectYMin / 2, _graphRectYMax / 2);
        }
    }

    public void ConnectNode(int id, string n)
    {
        for (int i = 0; i < _allNodes.Count; i++)
        {
            if (_allNodes[i].nodeName == n) //Si existe algun nodo con ese nombre
            {
                if (!_allNodes[id].connected.Contains(_allNodes[i])) //Si no lo contiene agrego
                {
                    _allConnected.Add(_allNodes[i]);
                    _allNodes[id].connected.Add(_allNodes[i]); //Conecto el seleccionado con el target
                    _allNodes[i].connected.Add(_allNodes[id]); //Conecto el target con el seleccionado
                    _allNodes[i].previous = _allNodes[id];
                    break;
                }
            }
        }
        Repaint();
    }

    public void DisconnectNode(int id, string n)
    {
        for (int i = 0; i < _allNodes.Count; i++)
        {
            if (_allNodes[i].nodeName == n) //Si existe algun nodo con ese nombre
            {
                if (_allNodes[id].connected.Contains(_allNodes[i])) //Si lo contiene remuevo
                {
                    _allConnected.Remove(_allNodes[i]);
                    _allNodes[id].connected.Remove(_allNodes[i]); //Desconecto el seleccionado con el target
                    _allNodes[i].connected.Remove(_allNodes[id]); //Desconecto el target con el seleccionado
                    _allNodes[i].previous = null;
                    break;
                }
            }
        }
        Repaint();
    }

    public List<FilterNode> GetFilterCriteria()
    {
        /*var lastNode = _allNodes.Where(x => x.connected.Count == 0).FirstOrDefault();
        _allConnected.Add(lastNode);*/
        return _allConnected;
    }
}
