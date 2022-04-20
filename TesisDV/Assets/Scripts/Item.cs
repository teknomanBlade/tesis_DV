using System.Collections;
using System.Collections.Generic;
using UnityEngine;

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

    protected virtual void Start() { }
    protected virtual void Update() { }

    public virtual void Interact()
    {
        
    }
}
