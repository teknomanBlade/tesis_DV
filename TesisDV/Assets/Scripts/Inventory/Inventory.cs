using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Inventory : MonoBehaviour
{
    [SerializeField] List<InventoryItem> items;
    [SerializeField] Slot[] itemSlots;
    [SerializeField] private CanvasGroup _myCanvasGroup;       
    private float fadeDelay = 1.1f;
    private bool isFaded;
    private void Awake()
    {
        _myCanvasGroup = GetComponent<CanvasGroup>();
        isFaded = true;
    }

    public void AddTrapItem(int slotIndex)
    {
        itemSlots[slotIndex].ActivateTrapKey();
    }

    public void AddItem(InventoryItem item)
    {
        Fade();
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

    public void DropItem()
    {
        for (int i = 0; i < itemSlots.Length; i++)
        {
            if(!itemSlots[i].IsFree())
           { 
               itemSlots[i].DropItem();
               //itemSlots[i].RemoveItem(); El remove va por lado del Slot.
               
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
    public void Fade()
    {
        StartCoroutine(DoFade(_myCanvasGroup.alpha, 1));
        isFaded = !isFaded;
    }
    public IEnumerator DoFade(float start, float end)
    {
        float counter = 0f;

        while(counter < fadeDelay)
        {
            counter += Time.deltaTime;
            _myCanvasGroup.alpha = Mathf.Lerp(start, end, counter / fadeDelay);

            yield return null;
        }
    }
}

