using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class LevelManagerEditorWindow : EditorWindow
{
    GameObject gizmoAuxiliar;
    bool showPath = false;

    [MenuItem("Tools/Management/LevelEditor")]
    public static void OpenWindow()
    {
        var window = GetWindow(typeof(LevelManagerEditorWindow)) as LevelManagerEditorWindow;
        window.Show();
    }

    private void OnEnable()
    {
        UnityEngine.Object preloadAuxiliar = Resources.Load("LevelEditor/LevelEditorAuxiliar");
        gizmoAuxiliar = Instantiate(preloadAuxiliar) as GameObject;
        gizmoAuxiliar.name = "LevelEditorAuxiliar";
    }

    private void OnFocus()
    {
        if (Selection.activeGameObject != null) Selection.SetActiveObjectWithContext(null, null);
    }

    private void OnInspectorUpdate()
    {
        Repaint();
    }

    private void OnGUI()
    {
        EditorGUILayout.LabelField("Level Editor", EditorStyles.boldLabel);
        showPath = EditorGUILayout.Toggle("Show path", showPath);
        //UPdate gizmo

        GUILayout.Space(10);
        GUILine();
        GUILayout.Space(10);
        
    }

    private void OnDisable()
    {
        DestroyImmediate(gizmoAuxiliar);
    }

    private void AddPoint(int index)
    {
        //gizmoAuxiliar.GetComponent
    }

    private void GUILine(int height = 1)
    {
        Rect rect = EditorGUILayout.GetControlRect(false, height);
        rect.height = height;
        EditorGUI.DrawRect(rect, new Color(0.5f, 0.5f, 0.5f, 1));
    }
}
