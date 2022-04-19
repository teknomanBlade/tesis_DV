using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InventoryItem : Item
{
    public override void Interact()
    {
        gameObject.SetActive(false);
    }
}
