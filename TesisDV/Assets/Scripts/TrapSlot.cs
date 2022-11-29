using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;
using UnityEngine;

public class TrapSlot : MonoBehaviour
{
    [SerializeField]
    private Sprite _trapSpriteEnabled;
    [SerializeField]
    private int _trapID;
    [SerializeField]
    private InventoryItem _item;
    [SerializeField]
    private Image _image;
    [SerializeField]
    private Image _keyImage;
    [SerializeField]
    private GameObject _myPrefab;
    [SerializeField]
    private int _itemID;
    [SerializeField]
    private CanvasGroup _slotCanvasGroup;
    private CanvasGroup _keyCanvasGroup;
    private float fadeDelay = 1.1f;
    private bool isFaded;
    private Vector3 auxVector;
    public Image SlotImage { get; set; }

    void Awake()
    {
        _slotCanvasGroup = GetComponent<CanvasGroup>();
        SlotImage = transform.GetChild(0).GetChild(0).GetComponent<Image>();
    }

    private void Update()
    {
        if (GameVars.Values.HasBoughtMicrowaveTrap && _trapID == 2)
        {
            SlotImage.sprite = _trapSpriteEnabled;
            GameVars.Values.HasBoughtMicrowaveTrap = false;
        }
        if (GameVars.Values.HasBoughtSlowingTrap && _trapID == 3)
        {
            SlotImage.sprite = _trapSpriteEnabled;
            GameVars.Values.HasBoughtSlowingTrap = false;
        }
        if (GameVars.Values.HasBoughtDartsTrap && _trapID == 4)
        {
            SlotImage.sprite = _trapSpriteEnabled;
            GameVars.Values.HasBoughtDartsTrap = false;
        }
        if (GameVars.Values.HasBoughtElectricTrap && _trapID == 5)
        {
            SlotImage.sprite = _trapSpriteEnabled;
            GameVars.Values.HasBoughtElectricTrap = false;
        }
    }
    public void ActivateImage()
    {
        //_image.enabled = true;
        
        SlotImage.enabled = true;
    }

    public void DeactivateImage()
    {
        //_image.enabled = false;
        SlotImage.enabled = false;
    }
}
