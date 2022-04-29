using System.Reflection;
using System.Net.Mime;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Slot : MonoBehaviour
{
    [SerializeField]
    private InventoryItem _item;
    [SerializeField]
    private Image _image;
    [SerializeField]
    private int _itemID;
    [SerializeField]
    private CanvasGroup _myCanvasGroup;  
    private float fadeDelay = 1.1f;    
    private bool isFaded;
    void Awake()
    {
        isFaded = true;
        _image = GetComponent<Image>();
        _myCanvasGroup = GetComponent<CanvasGroup>();
    }
    
    public bool IsFree()
    {
        if(_item == null)
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    public bool HasItem(InventoryItem item)
    {
    
        if(_item == item)
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    public bool HasItemID(int itemID)
    {
    
        if(_itemID == itemID)
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    public void SetItem(InventoryItem item)
    {
        _item = item;
        _image.color = new Color32(255,255,255,255);;
        _image.sprite = item.itemImage;
        _itemID = item.myCraftingID;
        Fade();
    }

    public void SetItemID(int itemID)
    {
        _itemID = itemID;
        
    }

    public void RemoveItem()
    {
        _item = null;
        _itemID = 0;
        _image.color = new Color32(0,0,0,255);;
        //_image.enabled = false;
        _image.sprite = null;
        Fade();
        
    }

    public void Fade()
    {
        StartCoroutine(DoFade(_myCanvasGroup.alpha, isFaded ? 1 : 0));
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
