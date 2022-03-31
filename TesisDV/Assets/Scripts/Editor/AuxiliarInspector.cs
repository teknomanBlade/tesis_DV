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

        lastTool = Tools.current;
        Tools.current = Tool.None;

        selectedPointInt = myAuxiliar.selectedPoint;
    }
}
