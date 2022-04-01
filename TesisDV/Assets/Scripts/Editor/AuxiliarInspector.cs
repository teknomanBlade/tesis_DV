using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(LevelEditorAuxiliar))]
[ExecuteInEditMode]
public class AuxiliarInspector : Editor
{
    LevelEditorAuxiliar myAuxiliar;
    int selectedPointInt;
    Tool lastTool = Tool.None;

    private void OnEnable()
    {
        myAuxiliar = target as LevelEditorAuxiliar;
        myAuxiliar.lvm = GameObject.Find("GameManagement").GetComponent<LevelManager>();

        lastTool = Tools.current;
        Tools.current = Tool.None;

        selectedPointInt = myAuxiliar.selectedPoint;
    }

    private void OnDisable()
    {
        Tools.current = lastTool;
    }

    private void OnSceneGUI()
    {
        Handles.color = Color.white;

        myAuxiliar.lvm.path[myAuxiliar.selectedPoint] = Handles.PositionHandle(myAuxiliar.lvm.path[myAuxiliar.selectedPoint], Quaternion.identity);

        for (int i = 0; i < myAuxiliar.lvm.path.Count; i++)
        {
            if (i != selectedPointInt)
            {
                if (i == 0) Handles.color = Color.green;
                if (i == myAuxiliar.lvm.path.Count - 1) Handles.color = Color.red;
                if (Handles.Button(myAuxiliar.lvm.path[i], Quaternion.identity, 0.5f, 0.5f, Handles.CubeHandleCap))
                {
                    
                    myAuxiliar.selectedPoint = i;
                    selectedPointInt = i;
                }
                Handles.color = Color.white;
            }
        }

        Handles.BeginGUI();
        var sceneViewHeight = EditorWindow.GetWindow<SceneView>().camera.scaledPixelHeight;
        var sceneViewWidth = EditorWindow.GetWindow<SceneView>().camera.scaledPixelWidth;

        GUILayout.BeginArea(new Rect(sceneViewWidth - 300, sceneViewHeight - 120, 300, 900));

        var r = EditorGUILayout.BeginVertical();

        GUI.color = new Color(0.6f, 0.6f, 0.6f);
        GUI.Box(r, GUIContent.none);

        EditorGUILayout.BeginHorizontal();
        if (GUI.Button(GUILayoutUtility.GetRect(20, 20, 20, 20), "Next"))
        {
            myAuxiliar.selectedPoint++;
            if (myAuxiliar.selectedPoint == myAuxiliar.lvm.path.Count)
            {
                myAuxiliar.selectedPoint = 0;
            }
            selectedPointInt = myAuxiliar.selectedPoint;
        }

        if (GUI.Button(GUILayoutUtility.GetRect(20, 20, 20, 20), "Prev"))
        {
            myAuxiliar.selectedPoint--;
            if (myAuxiliar.selectedPoint == -1)
            {
                myAuxiliar.selectedPoint = myAuxiliar.lvm.path.Count - 1;
            }
            selectedPointInt = myAuxiliar.selectedPoint;
        }
        EditorGUILayout.EndHorizontal();

        if (GUI.Button(GUILayoutUtility.GetRect(20, 20, 20, 20), "Add Point"))
        {
            myAuxiliar.AddPoint(myAuxiliar.selectedPoint);
            selectedPointInt = myAuxiliar.selectedPoint;
        }

        if (myAuxiliar.lvm.path != null)
        {
            myAuxiliar.lvm.path[myAuxiliar.selectedPoint] = EditorGUILayout.Vector3Field("Point: ", myAuxiliar.lvm.path[myAuxiliar.selectedPoint]);
        }

        if (GUI.Button(GUILayoutUtility.GetRect(20, 20, 20, 20), "Remove Point"))
        {
            myAuxiliar.RemovePoint(myAuxiliar.selectedPoint);
            selectedPointInt = myAuxiliar.selectedPoint;
        }

        EditorGUILayout.EndVertical();
        GUILayout.EndArea();
        Handles.EndGUI();
    }
}
