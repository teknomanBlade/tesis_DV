using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using System.Linq;
using UnityEngine;
using System;
using Object = UnityEngine.Object;

public class AssetFinder : EditorWindow
{
    private string _searchParamAsset;
    private string _searchParamFilter;
    private bool _isNullOrEmptyFinder;
    private List<UnityEngine.Object> _foundObjects;
    private List<FilterNode> filterList;
    private bool _hasNoResults;
    private GUIStyle _guiStyleLabel;
    private GUIStyle _guiStyleInfo;
    private UnityEngine.Object _myObj;
    private GUIStyle _guiStyleError;
    private Vector2 scrollPos;
    private AssetOperations assetOperations;
    private NodeFilterManagerWindow _nodeFilterManagerWindow;
    private void OnGUI()
    {
        AssetSearch();
    }

    public void Initialize()
    {
        _foundObjects = new List<UnityEngine.Object>();
        filterList = new List<FilterNode>();
        _guiStyleLabel = new GUIStyle()
        {
            fontSize = 14,
            fontStyle = FontStyle.Bold,
            alignment = TextAnchor.UpperLeft
        };
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
        Event e = Event.current;
        EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("Filter Type: ", _guiStyleLabel, GUILayout.Width(80));
            if(!string.IsNullOrEmpty(_searchParamFilter))
                EditorGUILayout.LabelField(_searchParamFilter, _guiStyleInfo ,GUILayout.Width(200));
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.Space();
        EditorGUILayout.BeginHorizontal();
                if (GUILayout.Button("Clean Filter"))
                {
                       _searchParamFilter = "";
                       filterList.Clear();
                       BeginSearch();
                }
                if (GUILayout.Button("Filter"))
                {
                    _nodeFilterManagerWindow = GetWindow<NodeFilterManagerWindow>();
                    _nodeFilterManagerWindow.maxSize = new Vector2(500, 100);
                    _nodeFilterManagerWindow.OnFilterListReady += FilterListReady;
                    _nodeFilterManagerWindow.Initialize();
                    _nodeFilterManagerWindow.Show();
                }
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("Search Asset: ", GUILayout.Width(80));
        _searchParamAsset = EditorGUILayout.TextField(_searchParamAsset, GUILayout.Width(320));
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("Clean Search"))
        {
            _searchParamAsset = "";
            _foundObjects.Clear();
        }
        if (e.keyCode == KeyCode.Return || GUILayout.Button("Begin Search"))
        {
            BeginSearch();
        }
        EditorGUILayout.EndHorizontal();

        if (_isNullOrEmptyFinder)
            EditorGUILayout.HelpBox("Por favor ingrese un valor", MessageType.Error);

        if (!string.IsNullOrEmpty(_searchParamFilter))
        {
            _hasNoResults = _foundObjects.Count == 0;
            _foundObjects = FilterFoundObjects(_foundObjects, filterList);
        }

        if (_foundObjects != null && _foundObjects.Count > 0)
        {
            scrollPos = EditorGUILayout.BeginScrollView(scrollPos, GUILayout.Height(250));
            _foundObjects.ForEach(x =>
            {
                EditorGUILayout.BeginHorizontal();
                if (x != null)
                {
                    EditorGUILayout.LabelField(x.name + " - " + x.GetType().Name);

                    if (GUILayout.Button("Manage"))
                    {
                        _myObj = x;
                        assetOperations = GetWindow<AssetOperations>();
                        assetOperations.maxSize = new Vector2(580, 280);
                        assetOperations.Initialize(_myObj);
                        assetOperations.Show();
                    }
                }

                EditorGUILayout.EndHorizontal();
            });

            EditorGUILayout.EndScrollView();
        }
        
        if (_hasNoResults)
            EditorGUILayout.HelpBox("No se han encontrado Assets con ese nombre", MessageType.Warning);

    }

    private void BeginSearch()
    {
        _isNullOrEmptyFinder = string.IsNullOrEmpty(_searchParamAsset);
        if (!_isNullOrEmptyFinder)
        {
            _foundObjects.Clear();
            string[] path = AssetDatabase.FindAssets(_searchParamAsset);

            path.ToList().ForEach(x =>
            {
                x = AssetDatabase.GUIDToAssetPath(x);
                var obj = AssetDatabase.LoadAssetAtPath(x, typeof(UnityEngine.Object));

                if (obj != null)
                {
                    _foundObjects.Add(obj);
                }

            });

            _hasNoResults = _foundObjects.Count == 0;
            //Debug.Log("Lista Objetos tiene algo? " + (_foundObjects.Count > 0) + " - Cantidad: " + _foundObjects.Count);

        }
        else
        {
            _foundObjects.Clear();
        }
    }

    private void FilterListReady(List<FilterNode> list)
    {
        if (list == null || list.Count == 0) return;

        filterList = list;
        filterList.ForEach(x => _searchParamFilter += x.nodeName + ";");
    }

    public List<Object> FilterFoundObjects(List<Object> foundObjects, List<FilterNode> filterList)
    {
        if (foundObjects == null || foundObjects.Count == 0 || foundObjects.Any(x => x == null)) return new List<Object>();

        var filterBy = filterList.SelectMany(type => foundObjects.Where(x => x.GetType().Name == type.nodeName));
        return filterBy.DefaultIfEmpty().ToList();
    }
}
