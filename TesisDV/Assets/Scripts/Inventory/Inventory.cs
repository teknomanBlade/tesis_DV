using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Inventory : MonoBehaviour
{
    private int _slots = 5;
    [SerializeField]
    private List <InventoryItem> mItems = new List<InventoryItem>();
    public event EventHandler<InventoryEventArgs> ItemAdded;
    public event EventHandler<InventoryEventArgs> ItemRemoved;

    public void AddItem(InventoryItem item)
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

    public void RemoveItem(IInventoryItem item)
    {

    }

    public bool ContainsItem(InventoryItem item)
    {
        for(int i = 0; i < mItems.Count; i++)
        {
            if(mItems[i] == item)
            {
                return true;
            }
        }
        return false;
    }

    public int ItemCount(InventoryItem item)
    {
        Debug.Log("es " + item);
        int number = 0;

        for(int i = 0; i < mItems.Count; i++)
        {
            Debug.Log("Im here");
            if(mItems[i] == item)
            {
                Debug.Log("Ayuda dios " + mItems[i]);
                number++;
            }
        }
        number++;
        Debug.Log(number);
        return number;
    }


}
