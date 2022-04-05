using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InventoryItem : MonoBehaviour, IInventoryItem
{
    [SerializeField]
    private string _itemName;
    [SerializeField]
    private Sprite _itemImage;
    public string itemName
    {
        get{ return _itemName;}   
    }


    public Sprite itemImage
    {
        get{ return _itemImage;} 
    }

    public void OnPickup()
    {
        Destroy(this.gameObject);
    }
}
