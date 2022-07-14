using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class AssetFinder : EditorWindow
{
    private string _searchParamAsset;
    private bool _isNullOrEmptyFinder;
    private List<UnityEngine.Object> _foundObjects;
    private bool _hasNoResults;
    private GUIStyle _guiStyleInfo;
    private UnityEngine.Object _myObj;
    private GUIStyle _guiStyleError;
    private Vector2 scrollPos;
    private AssetOperations assetOperations;
    private void OnGUI()
    {
        AssetSearch();
    }

    public void Initialize()
    {
        _foundObjects = new List<UnityEngine.Object>();
        _guiStyleInfo = new GUIStyle()
        {
            fontSize = 12,
            fontStyle = FontStyle.BoldAndItalic,
            alignment = TextAnchor.UpperLeft
        };
        _guiStyleError = new GUIStyle()
        {
            fontSize = 10,
            fontStyle = FontStyle.Bold,
            alignment = TextAnchor.UpperLeft
        };
    }

    public void AssetSearch()
    {
        EditorGUILayout.BeginHorizontal();
        var aux = _searchParamAsset;
        EditorGUILayout.LabelField("Search Asset: ", GUILayout.Width(80));
        _searchParamAsset = EditorGUILayout.TextField(_searchParamAsset, GUILayout.Width(200));
        if (GUILayout.Button("Begin Search"))
        {
            _isNullOrEmptyFinder = string.IsNullOrEmpty(_searchParamAsset);
            if (!_isNullOrEmptyFinder)
            {
                _foundObjects.Clear();
                string[] path = AssetDatabase.FindAssets(_searchParamAsset);

                for (int i = 0; i < path.Length; i++)
                {
                    path[i] = AssetDatabase.GUIDToAssetPath(path[i]);
                    var obj = AssetDatabase.LoadAssetAtPath(path[i], typeof(UnityEngine.Object));

                    if (obj != null)
                    {
                        _foundObjects.Add(obj);
                    }
                }
                _hasNoResults = _foundObjects.Count == 0;
                //Debug.Log("Lista Objetos tiene algo? " + (_foundObjects.Count > 0) + " - Cantidad: " + _foundObjects.Count);

            }
            else
            {
                _foundObjects.Clear();
            }
        }
        EditorGUILayout.EndHorizontal();

        if (_isNullOrEmptyFinder)
            EditorGUILayout.HelpBox("Por favor ingrese un valor", MessageType.Error);

        if (_foundObjects != null && _foundObjects.Count > 0)
        {
            scrollPos = EditorGUILayout.BeginScrollView(scrollPos, GUILayout.Height(250));
            for (int i = 0; i < _foundObjects.Count; i++)
            {
                EditorGUILayout.BeginHorizontal();
                if (_foundObjects[i] != null)
                {
                    EditorGUILayout.LabelField(_foundObjects[i].name + " - " + _foundObjects[i].GetType().Name);

                    if (GUILayout.Button("Manage"))
                    {
                        _myObj = _foundObjects[i];
                        assetOperations = GetWindow<AssetOperations>();
                        assetOperations.maxSize = new Vector2(580, 280);
                        assetOperations.Initialize(_myObj);
                        assetOperations.Show();
                    }
                }

                EditorGUILayout.EndHorizontal();
            }
            EditorGUILayout.EndScrollView();
        }
        if (_hasNoResults)
            EditorGUILayout.HelpBox("No se han encontrado Assets con ese nombre", MessageType.Warning);

    }
}
