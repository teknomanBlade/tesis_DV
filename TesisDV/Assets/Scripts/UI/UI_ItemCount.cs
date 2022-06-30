using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System.Linq;

public class UI_ItemCount : MonoBehaviour
{
    // Start is called before the first frame update
    public Text txtCount;
    public string itemName;
    public CraftingScreen craftingScreen;

    void Start()
    {
        craftingScreen = GetComponentInParent<CraftingScreen>();
        txtCount = GetComponent<Text>();
    }

    // Update is called once per frame
    void Update()
    {
        var itemCount = craftingScreen.tupleItemCount.Where(x=> x.Item1 == itemName).FirstOrDefault();

        if (itemCount != null)
        {
            txtCount.text = itemCount.Item2.ToString();
        }
    }
}
