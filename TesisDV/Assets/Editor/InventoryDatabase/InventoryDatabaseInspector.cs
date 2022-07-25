using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(InventoryDatabase)), CanEditMultipleObjects]
public class InventoryDatabaseInspector : Editor
{
    private GUIStyle myStyle;
    private InventoryDatabase _target;
    private bool IsNullOrEmptyNameScriptable { get; set; }
    private string _nameScriptable { get; set; }
    public Vector2 _scrollPos { get; private set; }

    private void OnEnable()
    {
        IsNullOrEmptyNameScriptable = false;
        _target = (InventoryDatabase)target;
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
        EditorGUILayout.LabelField("Inventory Database", myStyle);
        EditorGUILayout.Space();
        #region Create Scriptable Item
        EditorGUILayout.BeginHorizontal();
        _nameScriptable = EditorGUILayout.TextField("Scriptable Item Name:", _nameScriptable);

        if (GUILayout.Button(new GUIContent("+", "Add"), EditorStyles.miniButton, GUILayout.Height(20)))
        {
            if (!string.IsNullOrEmpty(_nameScriptable))
            {
                IsNullOrEmptyNameScriptable = false;
                var newItem = CreateInstance<ItemConfig>();
                var path = "Assets/Resources/ScriptableObjects/" + _nameScriptable + ".asset";
                path = AssetDatabase.GenerateUniqueAssetPath(path);
                AssetDatabase.CreateAsset(newItem, path);
                _target.Add(newItem);
                EditorUtility.SetDirty(newItem);
                Save();
            }
            else
            {
                IsNullOrEmptyNameScriptable = true;
            }
        }

        EditorGUILayout.EndHorizontal();

        if (IsNullOrEmptyNameScriptable)
        {
            EditorGUILayout.HelpBox("Por favor ingrese un nombre válido.", MessageType.Error);
        }
        #endregion
        DrawUILine(Color.grey);

        for (int i = 0; i < _target.ItemDatabase.Count; i++)
        {
            _scrollPos = EditorGUILayout.BeginScrollView(_scrollPos);
            var item = _target.GetItemConfig(i);
            EditorGUILayout.BeginHorizontal();

            EditorGUILayout.BeginVertical();
            EditorGUI.indentLevel++;
            EditorGUILayout.LabelField("ID: ", item.ID.ToString());
            if (item.TypeChoice == 2)
            {
                item.CraftingID = EditorGUILayout.IntField("Crafting ID: ", item.CraftingID);
            }
            item.ItemName = EditorGUILayout.TextField("Name: ", item.ItemName);
            item.Description = EditorGUILayout.TextField("Description: ", item.Description);
            item.PrefabItem = (GameObject)EditorGUILayout.ObjectField("Item Prefab: ", item.PrefabItem, typeof(GameObject), false);
            item.ItemSprite = (Sprite)EditorGUILayout.ObjectField("Sprite: ", item.ItemSprite, typeof(Sprite), false);
            item.TypeChoice = EditorGUILayout.Popup("Item Type", item.TypeChoice, item.ItemType);

            if(item.TypeChoice == 0)
            {
                item.HealthRecovery = EditorGUILayout.IntField("Health Recovery: ", item.HealthRecovery);
            }
            if (item.TypeChoice == 1)
            {
                item.Damage = EditorGUILayout.FloatField("Damage: ", item.Damage);
            }
            
            EditorGUILayout.EndVertical();

            EditorUtility.SetDirty(item);

            if (GUILayout.Button(new GUIContent("-", "Delete"), EditorStyles.miniButton, GUILayout.Width(20)))
            {
                var path = AssetDatabase.GetAssetPath(item);
                AssetDatabase.DeleteAsset(path);
                _target.RemoveAtReseed(i);
                Save();
            }

            EditorGUILayout.EndHorizontal();
            DrawUILine(Color.grey);
            EditorGUI.indentLevel--;
            EditorGUILayout.EndScrollView();
        }


    }
    public void DrawUILine(Color color, int thickness = 2, int padding = 10)
    {
        Rect r = EditorGUILayout.GetControlRect(GUILayout.Height(padding + thickness));
        r.height = thickness;
        r.y += padding / 2;
        r.x -= 2;
        r.width += 6;
        EditorGUI.DrawRect(r, color);
    }
    private void Save()
    {
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }
}
