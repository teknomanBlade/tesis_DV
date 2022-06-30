using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System.Linq;
using System;

public class CraftingScreen : MonoBehaviour, IScreen
{
    Button[] _buttons;
    InventoryItem[] inventoryItems;
    List<string> inventoryNames;
    public IEnumerable<Tuple<string, int>> tupleItemCount;

    private void Awake()
    {
        inventoryNames = new List<string>();
        inventoryNames.Add("Tar");
        inventoryNames.Add("Battery");
        inventoryNames.Add("Nails Box");
        inventoryNames.Add("TennisBallBox");
        inventoryNames.Add("Tennis Ball");
        inventoryNames.Add("Racket");
        inventoryNames.Add("RemoteControl");
        inventoryNames.Add("Screwdriver");
        inventoryNames.Add("RemoteControl");

        _buttons = GetComponentsInChildren<Button>();

        foreach (var button in _buttons)
        {
            button.interactable = false;
        }
    }

    void Start()
    {
        inventoryItems = FindObjectsOfType<InventoryItem>();

        tupleItemCount = EjercicioIA2P1(inventoryItems.ToList());

        this.gameObject.SetActive(false);


    }



    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Tab))
        {

            BTN_Back();
        }
    }
    public void BTN_Back()
    {
        ScreenManager.Instance.Pop();
    }

    public void Activate()
    {
        foreach (var button in _buttons)
        {
            button.interactable = true;
        }
    }

    public void Deactivate()
    {
        foreach (var button in _buttons)
        {
            button.interactable = false;
        }
    }

    public string Free()
    {
        Destroy(gameObject);
        return " ";
    }

    //IA2 -P1
    //IATP2 -P1
    //IA-TP2 -P1
    IEnumerable<Tuple<string, int>> EjercicioIA2P1(IEnumerable<InventoryItem> itemsInGame)
    {

        return inventoryNames.Aggregate(new List<Tuple<string, int>>(), (myItemCount, itemName) =>
        {

            var countInGame = itemsInGame.Where(x => x.itemName == itemName).Count();


            myItemCount.Add(new Tuple<string, int>(itemName, countInGame));


            return myItemCount;
        });
    }

   
}
