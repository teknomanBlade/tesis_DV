using System.Net.Mime;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class HUD : MonoBehaviour
{
    [SerializeField]
    private Inventory _inventory;
    private GameObject _inventoryBar;

    void Start()
    {
        _inventoryBar = GameObject.Find("InventoryBar");
        _inventory = _inventoryBar.GetComponent<Inventory>();
        _inventory.ItemAdded += AddItemHUD;
        _inventoryBar = GameObject.Find("InventoryBar");
    }

    private void AddItemHUD(object sender, InventoryEventArgs e)
    {
        foreach(Transform slot in _inventoryBar.transform)
        {
            Image image = slot.transform.GetChild(0).GetChild(0).GetComponent<Image>();

            if(!image.enabled)
            {
                image.enabled = true;
                image.sprite = e.Item.itemImage;


                break;
            }
        }

        
    }
}
