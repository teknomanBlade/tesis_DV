using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

public class AssetOperations : EditorWindow
{
    private GUIStyle _guiStyleInfo;
    private GUIStyle _guiStyleSubTitle;
    private UnityEngine.Object _myObj;
    private string _newName;
    private string _newPath;
    private bool _isPingObject;
    private bool _isNullOrEmptyRename;
    private bool _isNullOrEmptyMove;

    public void Initialize(Object myObj)
    {
        _isPingObject = true;
        _myObj = myObj;
        _guiStyleInfo = new GUIStyle()
        {
            fontSize = 14,
            fontStyle = FontStyle.BoldAndItalic,
            alignment = TextAnchor.UpperLeft
        };

        _guiStyleSubTitle = new GUIStyle()
        {
            fontSize = 10,
            fontStyle = FontStyle.Bold,
            alignment = TextAnchor.UpperLeft
        };

    }

    private void OnGUI()
    {

        EditorGUILayout.LabelField("Asset Selected: ", _guiStyleInfo);

        LoadSpaces(2);

        if (_isPingObject)
        {
            EditorGUIUtility.PingObject(_myObj);
            _isPingObject = false;
        }
        if (_myObj != null)
        {
            EditorGUILayout.LabelField("Path in Project: " + AssetDatabase.GetAssetPath(_myObj), _guiStyleSubTitle);
            EditorGUILayout.LabelField("Type: " + _myObj.GetType().Name, _guiStyleSubTitle);
        }
        EditorGUILayout.BeginHorizontal();
        _myObj = EditorGUILayout.ObjectField(_myObj, typeof(Object), true);

        EditorGUI.BeginDisabledGroup(_myObj == null);
        if (GUILayout.Button("Open"))
        {
            AssetDatabase.OpenAsset(_myObj.GetInstanceID());
        }

        EditorGUILayout.EndHorizontal();


        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("Move to RecycleBin"))
        {
            var path = AssetDatabase.GetAssetPath(_myObj);
            //Debug.Log("Move To RecycleBin Path: " + path);
            AssetDatabase.MoveAssetToTrash(path);
            UpdateDatabase();

        }

        if (GUILayout.Button("Delete"))
        {
            var path = AssetDatabase.GetAssetPath(_myObj);
            //Debug.Log("Delete Path: " + path);
            AssetDatabase.DeleteAsset(path);
            UpdateDatabase();
        }
        EditorGUILayout.EndHorizontal();

        LoadSpaces(2);
        EditorGUILayout.BeginHorizontal();
        _newName = EditorGUILayout.TextField("Rename Asset: ", _newName);
        if (GUILayout.Button("Rename"))
        {
            var path = AssetDatabase.GetAssetPath(_myObj);
            if (!string.IsNullOrEmpty(_newName))
            {
                _isNullOrEmptyRename = false;
                AssetDatabase.RenameAsset(path, _newName);
                UpdateDatabase();
            }
            else
            {
                _isNullOrEmptyRename = true;
            }

        }
        EditorGUILayout.EndHorizontal();
        if (_isNullOrEmptyRename)
            EditorGUILayout.HelpBox("Debe ingresar un valor para renombrar", MessageType.Error);

        EditorGUILayout.BeginHorizontal();
        _newPath = EditorGUILayout.TextField("Move Asset: ", _newPath);
        if (GUILayout.Button("Move"))
        {
            var path = AssetDatabase.GetAssetPath(_myObj);
            if (!string.IsNullOrEmpty(_newPath))
            {
                _isNullOrEmptyRename = false;
                var newPath = _newPath.Contains("\\") ? _newPath.Replace('\\', '/') : _newPath;
                var extension = Path.GetExtension(path);
                var filePath = "Assets/" + newPath + "/" + _myObj.name + extension;
                Debug.Log("New Path: " + newPath + "/" + _myObj.name + extension);
                AssetDatabase.MoveAsset(path, filePath);
                UpdateDatabase();
            }
            else
            {
                _isNullOrEmptyMove = true;
            }
        }
        EditorGUILayout.EndHorizontal();
        if (_isNullOrEmptyMove)
            EditorGUILayout.HelpBox("Debe ingresar un valor", MessageType.Error);


        EditorGUI.EndDisabledGroup();
    }
    public void LoadSpaces(int length)
    {
        for (int i = 0; i < length; i++)
        {
            EditorGUILayout.Space();
        }
    }

    public void UpdateDatabase()
    {
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }


}
