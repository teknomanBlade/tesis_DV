using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;

[CustomEditor(typeof(InventoryItem))]
public class ItemEditor : Editor
{
    #region Enum
    public enum ButtonType
    {
        MoveLeftNegative,
        MoveLeftPositive,
        MoveRightNegative,
        MoveRightPositive,
        MoveUpPositive,
        MoveUpNegative
    }
    #endregion

    #region Properties
    public string BtnMoveForwardText { get; set; }
    public string BtnMoveBackText { get; set; }
    public string BtnMoveUpText { get; set; }
    public string BtnMoveDownText { get; set; }
    public string BtnMoveLeftText { get; set; }
    public string BtnMoveRightText { get; set; }

    InventoryItem _target;
    private GUIStyle _guiStyleTitle;
    private GUIStyle _guiStyleSubTitle;
    public bool _showData { get; private set; }
    public bool _showUnitHandles { get; private set; }
    #endregion

    private void OnEnable()
    {
        //Obtenemos el target para despues poder usarlo y poder obtener los 4 posiciones necesarias para dibujar el bezier
        _target = (InventoryItem)target;
        BtnMoveForwardText = "Move Forward";
        BtnMoveBackText = "Move Back";
        BtnMoveUpText = "Move Up";
        BtnMoveDownText = "Move Down";
        BtnMoveLeftText = "Move Left";
        BtnMoveRightText = "Move Right";

        _guiStyleTitle = new GUIStyle()
        {
            fontSize = 20,
            alignment = TextAnchor.MiddleLeft,
            fontStyle = FontStyle.Bold,
            wordWrap = true
        };

        _guiStyleSubTitle = new GUIStyle()
        {
            fontSize = 12,
            alignment = TextAnchor.MiddleLeft,
            fontStyle = FontStyle.Bold,
            wordWrap = true
        };
    }

    private void OnSceneGUI()
    {
        Handles.BeginGUI();

        var v = EditorWindow.GetWindow<SceneView>().camera.pixelRect;
        //calculamos posición...
        /*var r = new Rect(v.width / 45, v.height - 80, 100, 40);
        if (GUI.Button(r, "Cat Info"))
        {
            _showData = !_showData;
        }*/
        var r2 = new Rect(v.width / 8, v.height - 80, 150, 40);
        if (GUI.Button(r2, "Activate Unit Handles"))
        {
            _showUnitHandles = !_showUnitHandles;
        }

        /*if (_showData)
            DrawInspectorInScene();*/

        if (_showUnitHandles)
        {
            var addValue = 30 / Vector3.Distance(Camera.current.transform.position, _target.transform.position);
            DrawButton(BtnMoveForwardText, _target.transform.position + _target.transform.forward * addValue, _target.transform.forward, ButtonType.MoveLeftPositive);
            DrawButton(BtnMoveBackText, _target.transform.position - _target.transform.forward * addValue, -_target.transform.forward, ButtonType.MoveLeftNegative);
            DrawButton(BtnMoveRightText, _target.transform.position + _target.transform.right * addValue, _target.transform.right, ButtonType.MoveRightPositive);
            DrawButton(BtnMoveLeftText, _target.transform.position - _target.transform.right * addValue, -_target.transform.right, ButtonType.MoveRightNegative);
            DrawButton(BtnMoveUpText, _target.transform.position + _target.transform.up * addValue, _target.transform.up, ButtonType.MoveUpPositive);
            DrawButton(BtnMoveDownText, _target.transform.position - _target.transform.up * addValue, -_target.transform.up, ButtonType.MoveUpNegative);
        }

        Handles.EndGUI();


    }

    private void DrawButton(string text, Vector3 position, Vector3 dir, ButtonType typ)
    {
        Vector3 p = Camera.current.WorldToScreenPoint(position);
        float size = 700 / Vector3.Distance(Camera.current.transform.position, position);
        Rect r = new Rect(p.x - (size / 2), Camera.current.pixelHeight - p.y, size + (text.Length * 3), size / 2);

        if (GUI.Button(r, text))
        {
            EditorSceneManager.MarkSceneDirty(EditorSceneManager.GetActiveScene());

            switch (typ)
            {
                case ButtonType.MoveLeftPositive:
                    _target.transform.position = _target.transform.position + dir;
                    Selection.activeObject = _target;
                    break;
                case ButtonType.MoveLeftNegative:
                    _target.transform.position = _target.transform.position + dir;
                    Selection.activeObject = _target;
                    break;
                case ButtonType.MoveRightPositive:
                    _target.transform.position = _target.transform.position + dir;
                    Selection.activeObject = _target;
                    break;
                case ButtonType.MoveRightNegative:
                    _target.transform.position = _target.transform.position + dir;
                    Selection.activeObject = _target;
                    break;
                case ButtonType.MoveUpPositive:
                    _target.transform.position = _target.transform.position + dir;
                    Selection.activeObject = _target;
                    break;
                case ButtonType.MoveUpNegative:
                    _target.transform.position = _target.transform.position + dir;
                    Selection.activeObject = _target;
                    break;
            }
        }
    }
}
