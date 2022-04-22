using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Inventory : MonoBehaviour
{
    [SerializeField] List<InventoryItem> items;
    [SerializeField] Slot[] itemSlots;

     public void AddItem(InventoryItem item)
    {
       for (int i = 0; i < itemSlots.Length; i++)
       {
           if(itemSlots[i].IsFree())
           {
               item.Interact();
               
               //itemSlots[i].Item = item;
               itemSlots[i].SetItem(item);

               return;
           }
       }
    } 

    public void AddItemID(InventoryItem item, int itemID)
    {
       for (int i = 0; i < itemSlots.Length; i++)
       {
           if(itemSlots[i].IsFree())
           {
               item.Interact();
               
               //itemSlots[i].Item = item;
               itemSlots[i].SetItem(item);
               itemSlots[i].SetItemID(itemID);

               return;
           }
       }
    }

    /* public void RemoveItem(InventoryItem item)
    {
        for (int i = 0; i < itemSlots.Length; i++)
        {
            if(itemSlots[i].HasItem(item))
            {
                //itemSlots[i].Item = null;
                itemSlots[i].RemoveItem();
                
            }
        }  
    } */

    public void RemoveItemID(int itemID)
    {
        for (int i = 0; i < itemSlots.Length; i++)
        {
            if(itemSlots[i].HasItemID(itemID))
            {
                //itemSlots[i].Item = null;
                itemSlots[i].RemoveItem();
                
            }
        }  
    }

    public bool IsFull()
    {
        for (int i = 0; i < itemSlots.Length; i++)
        {
            if(itemSlots[i].IsFree()) //itemSlots[i].Item = null)
            {
                return false;
            }
        }
        return true;
    }

    public bool ContainsItem(InventoryItem item)
    {
        for (int i = 0; i < itemSlots.Length; i++)
        {

            if(itemSlots[i].HasItem(item))
            {

                return true;
            }
        }

        return false;
    }

    public bool ContainsID(int itemID)
    {

        for (int i = 0; i < itemSlots.Length; i++)
        {

            if(itemSlots[i].HasItemID(itemID))
            {
                return true;
            }
        }

        return false;
    }

    public int ItemCount(InventoryItem item)
    {
        int number = 0;

        for (int i = 0; i < itemSlots.Length; i++)
        {
            if (itemSlots[i].HasItem(item))
            {
                Debug.Log("Soy +" + itemSlots[i] + " y tengo " + itemSlots[i].HasItem(item));   
                number++;
                
            }
        }
        return number;
    }

}

