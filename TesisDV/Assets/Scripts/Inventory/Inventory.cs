using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Inventory : MonoBehaviour
{
    //Cambiar por event.
    private TrapHotBar _trapHotBar;
    [SerializeField] List<InventoryItem> items;
    [SerializeField] Slot[] itemSlots;
    [SerializeField] private CanvasGroup _myCanvasGroup;   
    [SerializeField] private int _wittsAmount;    
    private float fadeDelay = 1.1f;
    private bool isFaded;

    public delegate void OnWittsAmountChangedDelegate(int witts);
    public event OnWittsAmountChangedDelegate OnWittsAmountChanged;
    private void Awake()
    {
        _myCanvasGroup = GetComponent<CanvasGroup>();
        isFaded = true;
        _trapHotBar = GameObject.Find("InventoryBar").GetComponent<TrapHotBar>(); 
    }

    void Start()
    {
        //OnWittsAmountChanged(_wittsAmount);
    }

    public void ReceiveWitts(int wittsAmount)
    {
        _wittsAmount += wittsAmount;
        OnWittsAmountChanged(_wittsAmount);
    }

    public void AddTrapItem(int slotIndex)
    {
        itemSlots[slotIndex].ActivateTrapKey();
    }

    public void AddItem(InventoryItem item)
    {
        //Fade();
        for (int i = 0; i < itemSlots.Length; i++)
        {
           if(itemSlots[i].HasItemID(item.myCraftingID))
           {
               item.Interact();   
               //itemSlots[i].Item = item;
               itemSlots[i].SetItem(item);
               //USAR EVENTO
               _trapHotBar.CheckRecipeRequirements(this);
                return;
           }
        }
        for (int i = 0; i < itemSlots.Length; i++)
        {
           if(itemSlots[i].IsFree())
           {
               item.Interact();   
               //itemSlots[i].Item = item;
               itemSlots[i].SetItem(item);
               //USAR EVENTO
               _trapHotBar.CheckRecipeRequirements(this);
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

    public void RemoveItemByID(int itemID)
    {
        for (int i = 0; i < itemSlots.Length; i++)
        {
            if (itemSlots[i].HasItemID(itemID))
            {
                itemSlots[i].RemoveItem();
                break;
            }
        }
    }

    public void RemoveItemID(int itemID, int amount)
    {
        int itemAmount = 0;

        for (int i = 0; i < itemSlots.Length; i++)
        {
            if(itemSlots[i].HasItemID(itemID))
            {
                //itemSlots[i].Item = null;
                itemSlots[i].RemoveItem();
                itemAmount++;
                if(itemAmount >= amount)
                {
                    _trapHotBar.CheckRecipeRequirements(this);
                    break;
                }
            }
        }  
    }

    public void RemoveWitts(int wittsNeeded)
    {
        _wittsAmount -= wittsNeeded;
        OnWittsAmountChanged(_wittsAmount);
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

    public bool ContainsID(int itemID, int amount)
    {
        int itemAmount = 0;

        for (int i = 0; i < itemSlots.Length; i++)
        {
            if(itemSlots[i].HasItemID(itemID))
            {
                itemAmount ++;
                if(itemAmount >= amount)
                {
                    return true;
                }
            }
        }

        return false;
    }

    public bool HasEnoughWitts (int wittsNeeded)
    {
        if (_wittsAmount >= wittsNeeded)
        {
            return true;
        }
        else
        {
            return false;
        }
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
    public int ItemCountByID(int itemID)
    {
        int number = 0;

        for (int i = 0; i < itemSlots.Length; i++)
        {
            if (itemSlots[i].HasItemID(itemID))
            {
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

