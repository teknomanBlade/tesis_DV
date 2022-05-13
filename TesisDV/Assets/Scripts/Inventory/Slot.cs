using System.Reflection;
using System.Net.Mime;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System.Linq;

public class Slot : MonoBehaviour
{
    [SerializeField]
    private InventoryItem _item;
    [SerializeField]
    private Image _image;
    [SerializeField]
    private GameObject _myPrefab;
    [SerializeField]
    private int _itemID;
    [SerializeField]
    private CanvasGroup _myCanvasGroup;  
    private float fadeDelay = 1.1f;    
    private bool isFaded;
    private Vector3 auxVector;

    void Awake()
    {
        isFaded = true;
        _image = transform.GetComponentsInChildren<Transform>()
            .Where(x => x.gameObject.name.Equals("ItemImage")).First().GetComponent<Image>();
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
        _item = null;
        _itemID = 0;
        _image.enabled = false;
        _image.color = new Color32(0,0,0,255);;
        _image.sprite = null;
        //Fade();
        
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
