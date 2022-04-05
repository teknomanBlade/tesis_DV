using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Inventory : MonoBehaviour
{
    private int _slots = 9;
    private List <IInventoryItem> mItems = new List<IInventoryItem>();
    public event EventHandler<InventoryEventArgs> ItemAdded;

    void Start()
    {
        
    }

    public void AddItem(IInventoryItem item)
    {
        if(mItems.Count < _slots)
        {
            mItems.Add(item);

            item.OnPickup();

            if(ItemAdded != null)
            {
                ItemAdded(this, new InventoryEventArgs(item));
            }
        }
    }
}
