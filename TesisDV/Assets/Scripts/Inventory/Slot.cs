using System.Net.Mime;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Slot : MonoBehaviour
{
    [SerializeField]
    private InventoryItem _item;
    [SerializeField]
    private Image _image;
    [SerializeField]
    private int _itemID;

    void Start()
    {
        _image = GetComponent<Image>();
    }
    
    public bool IsFree()
    {
        if(_item == null)
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    public bool HasItem(InventoryItem item)
    {
    
        if(_item == item)
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    public bool HasItemID(int itemID)
    {
    
        if(_itemID == itemID)
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    public void SetItem(InventoryItem item)
    {
        _item = item;
        _image.color = new Color32(255,255,255,255);;
        _image.sprite = item.itemImage;
        _itemID = item.myCraftingID;
    }

    public void SetItemID(int itemID)
    {
        _itemID = itemID;
    }

    public void RemoveItem()
    {
        _item = null;
        _itemID = 0;
        _image.color = new Color32(0,0,0,255);;
        //_image.enabled = false;
        _image.sprite = null;
    }

}
