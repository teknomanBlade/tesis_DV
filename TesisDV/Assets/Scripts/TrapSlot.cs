using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;
using UnityEngine;

public class TrapSlot : MonoBehaviour
{
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

    void Awake()
    {
        _slotCanvasGroup = GetComponent<CanvasGroup>();
    }
}
