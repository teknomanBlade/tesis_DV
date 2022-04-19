using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class Item : MonoBehaviour
{
    [SerializeField]
    private string _itemName;
    public string itemName { get { return _itemName; } }

    [SerializeField]
    private Sprite _itemImage;
    public Sprite itemImage
    {
        get
        {
            if (_itemImage != null) return _itemImage;
            return default(Sprite);
        }
    }

    public virtual void Interact()
    {
        
    }
}
