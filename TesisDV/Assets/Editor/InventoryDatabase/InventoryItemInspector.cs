using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(ItemConfig))]
public class InventoryItemInspector : Editor
{
    private GUIStyle myStyle;
    private ItemConfig _target;

    private void OnEnable()
    {
        _target = (ItemConfig)target;
        myStyle = new GUIStyle
        {
            fontStyle = FontStyle.BoldAndItalic,
            alignment = TextAnchor.MiddleCenter,
            fontSize = 20,
            wordWrap = true
        };
    }

    public override void OnInspectorGUI()
    {
        EditorGUILayout.Space();
        EditorGUILayout.LabelField("Inventory Item", myStyle);
        EditorGUILayout.Space();

        EditorGUILayout.BeginVertical();
        EditorGUI.indentLevel++;
        EditorGUILayout.LabelField("ID: ", _target.ID.ToString());
        if (_target.TypeChoice == 2)
        {
            _target.CraftingID = EditorGUILayout.IntField("Crafting ID: ", _target.CraftingID);
        }
        _target.ItemName = EditorGUILayout.TextField("Name: ", _target.ItemName);
        _target.Description = EditorGUILayout.TextField("Description: ", _target.Description);
        _target.PrefabItem = (GameObject)EditorGUILayout.ObjectField("Item Prefab: ", _target.PrefabItem, typeof(GameObject), false);
        _target.ItemSprite = (Sprite)EditorGUILayout.ObjectField("Sprite: ", _target.ItemSprite, typeof(Sprite), false);
        _target.TypeChoice = EditorGUILayout.Popup("Item Type", _target.TypeChoice, _target.ItemType);

        if (_target.TypeChoice == 0)
        {
            _target.HealthRecovery = EditorGUILayout.IntField("Health Recovery: ", _target.HealthRecovery);
        }
        if (_target.TypeChoice == 1)
        {
            _target.Damage = EditorGUILayout.FloatField("Damage: ", _target.Damage);
        }

        EditorGUILayout.EndVertical();
    }
}
