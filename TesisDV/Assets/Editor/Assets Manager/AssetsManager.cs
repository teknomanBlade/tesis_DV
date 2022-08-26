using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

public class AssetsManager : EditorWindow
{
    #region Properties
    public const string DIALOG_TITLE = "¡ATENCIÓN!";
    public const string DIALOG_MESSAGE = "¿Está seguro de borrar la carpeta seleccionada?";
    public const string DIALOG_OK = "OK";
    public const string DIALOG_CANCEL = "Cancelar";
    private string _folderName;
    private string _folderNameDelete;
    private string _folderSource;
    private string _folderDestiny;
    private GUIStyle _guiStyleError;
    private GUIStyle _guiStyleSubTitle;
    private bool _directoryNotEmpty;
    private bool _directoryNotExists;
    private bool _isBackSlash;
    private bool _isSlash;
    private bool _onlySlashesAllowedCreate;
    private bool _onlySlashesAllowedDelete;
    private bool _isNullOrEmptyDelete;
    private bool _isNullOrEmptyCreate;
    private bool _isNullOrEmptyMove;
    private bool _originAndDestinyEquals;
    private bool _destinyFolderExists;
    private bool _sourceFolderNotExists;
    private AssetFinder _assetFinder;
    public string prev { get; private set; }
    public string prevAlt { get; private set; }
    public string slash { get; private set; }
    #endregion

    [MenuItem("Game Assets Operations/Assets Manager")]
    public static void OpenWindow()
    {
        var assetsFolderManager = GetWindow<AssetsManager>();
        assetsFolderManager.maxSize = new Vector2(900, 500);
        assetsFolderManager.Initialize();
        assetsFolderManager.Show();
    }

    private void Initialize()
    {
        prevAlt = "";
        _onlySlashesAllowedCreate = false;
        _onlySlashesAllowedDelete = false;
        _directoryNotExists = false;
        _guiStyleSubTitle = new GUIStyle()
        {
            fontSize = 12,
            fontStyle = FontStyle.Bold,
            alignment = TextAnchor.UpperLeft
        };
        _guiStyleSubTitle.normal.textColor = Color.black;
    }

    private void OnGUI()
    {
        #region Create Folder
        EditorGUILayout.LabelField("Assets Folder Manager", _guiStyleSubTitle);
        EditorGUILayout.Space();

        _folderName = EditorGUILayout.TextField("Folder Name: ", _folderName);

        if (GUILayout.Button("Create New Folder"))
        {
            var projectPath = Directory.GetCurrentDirectory();
            var assetsPath = projectPath + "\\Assets\\";
            _isNullOrEmptyCreate = string.IsNullOrEmpty(_folderName);
            if (!_isNullOrEmptyCreate)
            {
                slash = "";
                prev = "";
                string[] folders = GetFolders(_folderName, true);

                if (folders != null)
                {
                    for (int i = 0; i < folders.Length; i++)
                    {
                        int j = i;
                        if (j > 0)
                        {
                            slash = "/";
                            j--;
                            prev = folders[j];
                            prevAlt += slash + folders[j];
                        }
                        var pathPrev = "";
                        if (!string.IsNullOrEmpty(prev))
                        {
                            pathPrev = prev + "\\";
                        }

                        if (!Directory.Exists(assetsPath + pathPrev + folders[i]))
                        {
                            AssetDatabase.CreateFolder("Assets" + prevAlt, folders[i]);
                        }
                    }
                }
                prevAlt = "";
            }
        }
        if (_isNullOrEmptyCreate)
            EditorGUILayout.HelpBox("Tiene que ingresar un valor", MessageType.Error);

        if (_onlySlashesAllowedCreate)
            EditorGUILayout.HelpBox("Ingrese sólo barra o barra invertida", MessageType.Error);
        #endregion

        #region Move Folder
        _folderSource = EditorGUILayout.TextField("Source Folder: ", _folderSource);
        _folderDestiny = EditorGUILayout.TextField("Destiny Folder: ", _folderDestiny);

        if (GUILayout.Button("Move Folder"))
        {
            if (!string.IsNullOrEmpty(_folderSource) && !string.IsNullOrEmpty(_folderDestiny))
            {
                _folderSource = _folderSource.Replace('/', '\\');
                _folderDestiny = _folderDestiny.Replace('/', '\\');
                if (!_folderSource.Equals(_folderDestiny))
                {
                    var projectPath = Directory.GetCurrentDirectory();
                    var assetsPath = projectPath + "\\Assets\\";
                    var pathSource = assetsPath + _folderSource;
                    var pathDestiny = assetsPath + _folderDestiny;

                    if (!Directory.Exists(pathSource))
                    {
                        _sourceFolderNotExists = true;
                    }
                    else
                    {
                        if (!Directory.Exists(pathDestiny))
                        {
                            _originAndDestinyEquals = false;
                            _isNullOrEmptyMove = false;
                            _destinyFolderExists = false;
                            _sourceFolderNotExists = false;
                            Directory.Move(pathSource, pathDestiny);
                            AssetDatabase.Refresh();
                        }
                        else
                        {
                            _destinyFolderExists = true;
                        }
                    }
                }
                else
                {
                    _originAndDestinyEquals = true;
                }
            }
            else
            {
                _isNullOrEmptyMove = true;
            }


        }
        if (_isNullOrEmptyMove)
        {
            EditorGUILayout.HelpBox("Los campos 'Origen' y 'Destino' tienen que tener un valor", MessageType.Error);
        }
        if (_sourceFolderNotExists)
        {
            EditorGUILayout.HelpBox("La carpeta 'Origen' no existe", MessageType.Error);
        }
        if (_destinyFolderExists)
        {
            EditorGUILayout.HelpBox("La carpeta 'Destino' ya existe", MessageType.Error);
        }

        if (_originAndDestinyEquals)
        {
            EditorGUILayout.HelpBox("Las carpetas 'Origen' y 'Destino' no pueden ser iguales", MessageType.Error);
        }
        #endregion

        #region Delete Folder
        _folderNameDelete = EditorGUILayout.TextField("Folder Name To Delete: ", _folderNameDelete);
        if (GUILayout.Button("Delete Folder"))
        {

            var projectPath = Directory.GetCurrentDirectory();
            var assetsPath = projectPath + "\\Assets\\";
            try
            {
                if (!string.IsNullOrEmpty(_folderNameDelete))
                {
                    var okPressed = EditorUtility.DisplayDialog(DIALOG_TITLE, DIALOG_MESSAGE, DIALOG_OK, DIALOG_CANCEL);
                    if (okPressed)
                    {
                        slash = "";

                        _isNullOrEmptyDelete = false;
                        string[] folders = GetFolders(_folderNameDelete, false);

                        if (folders != null)
                        {
                            for (int i = 0; i < folders.Length; i++)
                            {
                                int j = i;
                                if (j > 0)
                                {
                                    j--;
                                    slash = "\\";
                                    prevAlt += folders[j] + slash;
                                }
                                var path = assetsPath + prevAlt + folders[i];
                                if (Directory.Exists(path) && i == folders.Length - 1)
                                {
                                    FileUtil.DeleteFileOrDirectory(path);
                                    //Directory.Delete(path);
                                    _directoryNotExists = false;
                                }
                                else
                                {
                                    _directoryNotExists = true;
                                }
                            }
                        }
                        prevAlt = "";

                        _directoryNotEmpty = false;

                    }
                }
                else
                {
                    _isNullOrEmptyDelete = true;
                }
            }
            catch (IOException e)
            {
                EditorGUILayout.HelpBox(e.Message, MessageType.Error);
                _directoryNotEmpty = true;
            }

            AssetDatabase.Refresh();
        }

        if (_isNullOrEmptyDelete)
            EditorGUILayout.HelpBox("Debe ingresar un valor", MessageType.Error);

        if (_onlySlashesAllowedDelete)
            EditorGUILayout.HelpBox("Ingrese sólo barra o barra invertida", MessageType.Error);

        if (_directoryNotEmpty)
        {
            EditorGUILayout.HelpBox("El directorio no está vacío", MessageType.Error);
        }

        if (_directoryNotExists)
        {
            EditorGUILayout.HelpBox("El directorio a borrar no existe", MessageType.Error);
        }
        #endregion

        //Debug.Log("--- DESPUES BOTON CREATE " + _isNullOrEmpty);

        EditorGUILayout.Space();
        EditorGUILayout.LabelField("Asset Finder", _guiStyleSubTitle);
        EditorGUILayout.Space();
        if (GUILayout.Button("Open Asset Finder"))
        {
            _assetFinder = GetWindow<AssetFinder>();
            _assetFinder.maxSize = new Vector2(750, 600);
            _assetFinder.Initialize();
            _assetFinder.Show();
        }

    }

    #region Methods
    public string[] GetFolders(string folder, bool create)
    {
        string[] folders = null;
        _isBackSlash = folder.Contains("\\");
        _isSlash = folder.Contains("/");
        if (_isBackSlash || _isSlash)
        {
            folders = folder.Split('\\', '/');
            if (create)
                _onlySlashesAllowedCreate = false;
            else
                _onlySlashesAllowedDelete = false;
        }
        else if (IsAnySpecialCharacterThanSlashes(folder))
        {
            if (create)
                _onlySlashesAllowedCreate = true;
            else
                _onlySlashesAllowedDelete = true;
        }
        else
        {
            folders = folder.Split(' ');
            if (create)
                _onlySlashesAllowedCreate = false;
            else
                _onlySlashesAllowedDelete = false;
        }

        return folders;
    }

    public bool IsAnySpecialCharacterThanSlashes(string folder)
    {
        return folder.Contains(".") || folder.Contains("-") ||
            folder.Contains(":") || folder.Contains(",") ||
            folder.Contains(";") || folder.Contains("_") ||
            folder.Contains("|") || folder.Contains("·") ||
            folder.Contains("$") || folder.Contains("%") ||
            folder.Contains("&") || folder.Contains("[") ||
            folder.Contains("]") || folder.Contains("{") ||
            folder.Contains("}") || folder.Contains("+") ||
            folder.Contains("*") || folder.Contains("^") ||
            folder.Contains("`") || folder.Contains("¨") ||
            folder.Contains("'") || folder.Contains("!") ||
            folder.Contains("¡") || folder.Contains("@");
    }
    #endregion


}