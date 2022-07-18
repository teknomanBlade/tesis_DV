using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class NodeFilterManagerWindow : EditorWindow
{
    private GUIStyle _myStyle;
    private bool _isCurrentNameEmpty;
    private NodeDisplayWindow _nodeWindow;
    private string _currentName;

    /*public static void OpenWindow()
    {
        var myWindow = GetWindow<NodeFilterManagerWindow>();

        myWindow._nodeWindow = GetWindow<NodeDisplayWindow>();
        myWindow._nodeWindow.SetInitialStates();
        myWindow._nodeWindow.Show();
    }*/
    public void Initialize()
    {
        _myStyle = new GUIStyle
        {
            fontSize = 20,
            alignment = TextAnchor.MiddleCenter,
            fontStyle = FontStyle.BoldAndItalic,
            wordWrap = true
        };
        _nodeWindow = GetWindow<NodeDisplayWindow>();
        _nodeWindow.SetInitialStates();
        _nodeWindow.Show();
    }
    private void OnGUI()
    {
        EditorGUILayout.LabelField("Assets Filter", _myStyle);
        EditorGUILayout.Space();

        _currentName = EditorGUILayout.TextField("Nombre: ", _currentName);
        EditorGUILayout.Space();
        if (GUILayout.Button("Create Filter Node", GUILayout.Width(150), GUILayout.Height(30)))
        {
            _isCurrentNameEmpty = string.IsNullOrEmpty(_currentName);
            if (!_isCurrentNameEmpty)
            {
                _nodeWindow.AddNode(_currentName);
                _currentName = "";
            }
        }

        if (_isCurrentNameEmpty)
        {
            EditorGUILayout.HelpBox("Por favor ingrese un valor", MessageType.Error);
        }
    }

    private void OnDestroy()
    {
       if(_nodeWindow != null) _nodeWindow.Close();
    }
}
