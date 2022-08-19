using System.Net.Mime;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public enum ItemType { Crafting, Heal, Weapon }
public abstract class Item : MonoBehaviour
{
    [SerializeField]
    protected string _itemName;
    public string itemName { get { return _itemName; } }

    [SerializeField]
    protected Sprite _itemImage;
    public Sprite itemImage
    {
        get
        {
            if (_itemImage != null) return _itemImage;
            return default(Sprite);
        }
    }
    public ItemType itemType;
    

    protected virtual void Start() { }
    protected virtual void Update() { }

    public virtual void Interact()
    {
        
    }
}
