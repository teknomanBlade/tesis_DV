using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Inventory : MonoBehaviour
{
    private int _slots = 5;
    [SerializeField]
    private List <string> mItems = new List<string>();
    private InventoryItem[] inventoryContainer;
    public event EventHandler<InventoryEventArgs> ItemAdded;
    public event EventHandler<InventoryEventArgs> ItemRemoved;

    public void AddItem(InventoryItem item)
    {
        if(mItems.Count < _slots)
        {
            mItems.Add(item.ToString());


            item.OnPickup();

            if(ItemAdded != null)
            {
                ItemAdded(this, new InventoryEventArgs(item));
            }
        }
    }

    public void RemoveItem(InventoryItem item)
    {
        //mItems.Remove(item);

        if(ItemRemoved != null)
        {
            ItemRemoved(this, new InventoryEventArgs(item));
        }
    }

    /* public bool ContainsItem(InventoryItem item)
    {
        for(int i = 0; i < mItems.Count; i++)
        {
            if(mItems[i] == item)
            {
                return true;
            }
        }
        return false;
    } */

    public int ItemCount(InventoryItem item)
    {
        int number = 0;
        
        string itemfor = item.ToString();
        Debug.Log(itemfor);
        if(mItems.Contains(itemfor))
        {
            Debug.Log("SIISISIS");
            number++;
        }
        Debug.Log("nonononono");

        /* for(int i = 0; i < mItems.Count; i++)
        {
            Debug.Log("Item Count");
            if(mItems[i] == item)
            {
                Debug.Log("Ayuda " + mItems[i]);
                number++;
            }
        }
        number++; */
        Debug.Log(number);
        return number;
    }


}
