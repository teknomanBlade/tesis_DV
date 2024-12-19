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
    public Image SlotTrapImage;
    public Image SlotImage;
    [SerializeField]
    private Animator _animKeySlot;

    void Awake()
    {
        _slotCanvasGroup = GetComponent<CanvasGroup>();
        SlotImage = GetComponent<Image>();
        SlotTrapImage = transform.GetChild(0).GetChild(0).GetComponent<Image>();
        _animKeySlot = transform.GetChild(1).GetComponent<Animator>();
    }

    private void Update()
    {
        if (GameVars.Values.HasBoughtSlowingTrap && _trapID == 2)
        {
            SlotTrapImage.sprite = _trapSpriteEnabled;
            GameVars.Values.HasBoughtSlowingTrap = false;
        }
        if (GameVars.Values.HasBoughtMicrowaveTrap && _trapID == 3)
        {
            SlotTrapImage.sprite = _trapSpriteEnabled;
            GameVars.Values.HasBoughtMicrowaveTrap = false;
        }
        if (GameVars.Values.HasBoughtElectricTrap && _trapID == 4)
        {
            SlotTrapImage.sprite = _trapSpriteEnabled;
            GameVars.Values.HasBoughtElectricTrap = false;
        }
        if (GameVars.Values.HasBoughtPaintballMinigunTrap && _trapID == 5)
        {
            SlotTrapImage.sprite = _trapSpriteEnabled;
            GameVars.Values.HasBoughtPaintballMinigunTrap = false;
        }
        if (GameVars.Values.HasBoughtTeslaCoilGenerator && _trapID == 6)
        {
            SlotTrapImage.sprite = _trapSpriteEnabled;
            GameVars.Values.HasBoughtTeslaCoilGenerator = false;
        }
    }

    IEnumerator PlayKeySlotAnim()
    {
        _animKeySlot.SetBool("IsHighlighted", true);
        yield return new WaitForSeconds(2f);
        _animKeySlot.SetBool("IsHighlighted", false);
    }

    public void ActivateImage()
    {
        PlayKeySlotAnimHighlight();
        SlotImage.color = Color.white;
        SlotTrapImage.enabled = true;
    }

    public void DeactivateImage()
    {
        if (SlotTrapImage == null) return;
        SlotImage.color = Color.gray;
        SlotTrapImage.enabled = false;
    }

    public void PlayKeySlotAnimHighlight() 
    {
        if (!gameObject.activeSelf) return;

        StartCoroutine(PlayKeySlotAnim());
    }
}
