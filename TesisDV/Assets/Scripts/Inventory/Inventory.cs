using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class Inventory : MonoBehaviour
{
    //Cambiar por event.
    private TrapHotBar _trapHotBar;
    [SerializeField] List<InventoryItem> items;
    [SerializeField] Slot[] itemSlots;
    [SerializeField] WeaponSlot[] weaponSlots;
    [SerializeField] WeaponSlotHotBar weaponSlotsHotBar;
    private int _currentWeaponIndex = 0;
    [SerializeField] private CanvasGroup _myCanvasGroup;   
    [SerializeField] private float _wittsAmount;    
    private float fadeDelay = 1.1f;

    private bool isFaded;

    public delegate void OnWittsAmountChangedDelegate(float witts);
    public event OnWittsAmountChangedDelegate OnWittsAmountChanged;
    private void Awake()
    {
        _myCanvasGroup = GetComponent<CanvasGroup>();
        isFaded = true;
        _trapHotBar = GameObject.Find("InventoryBar").GetComponent<TrapHotBar>();
        weaponSlotsHotBar = FindObjectsOfType<WeaponSlotHotBar>(true).FirstOrDefault();
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
        //Si es tipo Weapon lo agregamos a un WeaponSlot.
        if (item.itemType == ItemType.Weapon)
        {
            for (int i = 0; i < weaponSlots.Length; i++)
            {
                if(weaponSlots[i].IsFree())
                {
                    item.Interact();   

                    weaponSlots[i].SetItem(item);
                    weaponSlotsHotBar.SetItem(item);

                    _trapHotBar.CheckRecipeRequirements(this);
                    return;
                }
            }
        }
        else
        {
            //Si no, lo agregamos a un ItemSlot.
            if (item.myCraftingID == 0)
                return;

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
        for (int i = 0; i < weaponSlots.Length; i++)
        {
            if (weaponSlots[i].HasItemID(itemID))
            {
                weaponSlots[i].RemoveItem();
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

    public bool ContainsID(int itemID, int amount) //Considerar separar conteo de armas e items.
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
        for (int i = 0; i < weaponSlots.Length; i++)
        {
            if(weaponSlots[i].HasItemID(itemID))
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
    public int ItemCountByID(int itemID)    //Considerar separar conteo de armas e items.
    {
        int number = 0;

        for (int i = 0; i < itemSlots.Length; i++)
        {
            if (itemSlots[i].HasItemID(itemID))
            {
                number++;
            }
        }
        for (int i = 0; i < weaponSlots.Length; i++)
        {
            if (weaponSlots[i].HasItemID(itemID))
            {
                number++;
            }
        }
        return number;
    }

    public bool IsThereAnotherWeapon()
    {
        int number = 0;

        for(int i = 0; i < weaponSlots.Length; i++)
        {
            if(!weaponSlots[i].IsFree())
            {
                number++;
            }
        }

        if(number >= 2) //Hay mas de dos armas.
        {
            return true;
        }
        else //Solo hay 1 arma.
        {
            return false;
        } 
    }

    public int GetNextWeapon()
    {
        int numberOfWeapons = 0;

        for(int i = 0; i < weaponSlots.Length; i++)
        {
            if(!weaponSlots[i].IsFree())
            {
                numberOfWeapons++;
            }
        }

        if(numberOfWeapons >= 2) //Hay mas de dos armas.
        {
            if(_currentWeaponIndex + 1 < weaponSlots.Length)
            {
                _currentWeaponIndex ++;
                Debug.Log(weaponSlots[_currentWeaponIndex].GetItemID());
                return weaponSlots[_currentWeaponIndex].GetItemID();
                
            }
            else
            {
                _currentWeaponIndex = 0;
                //Debug.Log(weaponSlots[_currentWeaponIndex].GetItemID());
                return weaponSlots[_currentWeaponIndex].GetItemID();
            }
            //return true;
        }
        else
        {
            //Debug.Log("soy un cornudo");
            return 0;
            
        }
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

