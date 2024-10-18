using System.Reflection;
using System.Net.Mime;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System.Linq;

public class WeaponSlot : MonoBehaviour
{
    [SerializeField] private InventoryItem _item;
    [SerializeField] private Image _image;
    [SerializeField] private GameObject _myPrefab;
    [SerializeField] private int _itemID;
    [SerializeField] private CanvasGroup _slotCanvasGroup;
    private CanvasGroup _keyCanvasGroup;
    private float fadeDelay = 1.1f;    
    private bool isFaded;
    private Vector3 auxVector;

    void Awake()
    {
        isFaded = true;
        //_keyImage = transform.GetComponentsInChildren<Transform>()
            //.Where(x => x.gameObject.name.Equals("KeyImage")).First().GetComponent<Image>();
        //_keyCanvasGroup = _keyImage.GetComponent<CanvasGroup>();
        _image = transform.GetComponentsInChildren<Transform>()
            .Where(x => x.gameObject.name.Equals("ItemImage")).First().GetComponent<Image>();
        _slotCanvasGroup = GetComponent<CanvasGroup>();
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

    public void ActivateTrapKey()
    {
        Fade(_keyCanvasGroup);
    }

    public void SetItem(InventoryItem item)
    {
        _item = item;
        _image.enabled = true;
        _image.color = new Color32(255,255,255,255);
        _image.sprite = item.itemImage;
        _itemID = item.myCraftingID;
        _myPrefab = item.myPrefab;
        //Fade(); 
    }

    public void SetItemID(int itemID)
    {
        _itemID = itemID;
    }

    public int GetItemID()
    {
        return _itemID;
    }

    public void DropItem()
    {
        //Primer metodo: Instanciar.
        GameObject aux = Instantiate(_myPrefab, GameVars.Values.GetPlayerPrefabPlacement(), Quaternion.identity);
        aux.SetActive(true);
        aux.gameObject.GetComponent<Collider>().enabled = true;
        auxVector = new Vector3(aux.transform.position.x, .25f, aux.transform.position.z);
        aux.transform.position = auxVector;

        //Segundo método: Reposicionar. Creo que es mejor, debería ver si puedo hacer andar la animación de agarre de nuevo.
        //_item.gameObject.transform.position = GameVars.Values.GetPlayerPrefabPlacement();
        //_item.SetActiveAgain();
        //_item.EnableColliderAgain();
        RemoveItem();
    }

    public void RemoveItem()
    {
        ResetSlot();
        //Fade();   
    }

    private void ResetSlot()
    {
        _item = null;
        _itemID = 0;
        _image.enabled = false;
        _image.color = new Color32(0,0,0,255);;
        _image.sprite = null;
    }

    public void Fade(CanvasGroup canvasGroup)
    {
        StartCoroutine(DoFade(canvasGroup, canvasGroup.alpha, isFaded ? 1 : 0));
        isFaded = !isFaded;
    }

    public IEnumerator DoFade(CanvasGroup canvasGroup,float start, float end)
    {
        float counter = 0f;

        while(counter < fadeDelay)
        {
            counter += Time.deltaTime;
            canvasGroup.alpha = Mathf.Lerp(start, end, counter / fadeDelay);

            yield return null;
        }
    }

}
