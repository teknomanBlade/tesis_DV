using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FERNPaintballMinigun : Trap, IMovable, IInteractable
{
    private float _maxLife = 100f;
    [SerializeField] private float _currentLife;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void BecomeMovable()
    {
        //GameVars.Values.currentShotsTrap1 = shotsLeft;
        //GameObject aux = Instantiate(blueprintPrefab, transform.position, transform.rotation);
        //aux.GetComponent<StaticBlueprint>().SpendMaterials(false);
        //aux.GetComponent<StaticBlueprint>().CanBeCancelled(false);
        _myTrapBase.ResetBase();
        Destroy(gameObject);
    }

    public void Interact()
    {

    }
}
