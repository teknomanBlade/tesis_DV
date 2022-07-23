using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "Item", menuName = "Items/MyItem")]
public class ItemConfig : ScriptableObject
{
    public int ID;
    public int CraftingID;
    public GameObject PrefabItem;
    public Sprite ItemSprite;
    public string ItemName;
    public string Description;
    public int HealthRecovery;
    public float Damage;
    public TypeItem TypeItem;
}

public enum TypeItem
{
    None,
    Heal,
    Weapon,
    Crafting
}
