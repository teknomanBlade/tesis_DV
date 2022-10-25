using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class BaseballBat : Melee
{
    [SerializeField] private Mesh _damagedBaseballBatMesh;
    [SerializeField] private Mesh _newBaseballBatMesh;
    private MeshRenderer _renderer;
    private MeshFilter _meshFilter;
    private Quaternion _startingRotation;
    private bool hitStateActive;
    [SerializeField]
    private bool _isDestroyed;
    // Start is called before the first frame update
    void Awake()
    {
        damageAmount = 3;
        _startingRotation = transform.localRotation;
        _renderer = GetComponent<MeshRenderer>();
        _meshFilter = GetComponent<MeshFilter>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public override void MeleeAttack()
    {
        if (!IsAttacking)
            StartCoroutine(Attack("IsAttacking", "BaseballBatSwing"));
    }

    IEnumerator Attack(string param, string name)
    {
        IsAttacking = true;
        _player.Cam.ShakeRacketSwing();
        anim.SetBool(param, true);
        GameVars.Values.soundManager.PlaySoundAtPoint("RacketSwing", transform.position, 0.09f);
        var playerCollider = _player.GetComponent<BoxCollider>();
        var clips = anim.runtimeAnimatorController.animationClips;
        float time = clips.First(x => x.name == name).length;
        if (time / 2 < 0.2f)
        {
            playerCollider.enabled = true;
        }
        yield return new WaitForSeconds(time);
        anim.SetBool(param, false);
        playerCollider.enabled = false;
        IsAttacking = false;
        hitStateActive = false;
    }
    public void RemoveFromParent()
    {
        transform.parent.parent = null;
    }
    public void SetDamagedBaseballBat()
    {
        _meshFilter.mesh = _damagedBaseballBatMesh;
        anim.SetBool("IsDestroyed", true);
        //transform.localRotation = Quaternion.Euler(2.658f, 42.094f, 73.143f);
    }
    /*protected override void OnContactEffect(Collider other)
    {
        if (IsAttacking)
        {
            var enemyGray = other.GetComponent<Enemy>(); //Cambiar a la clase padre despues como todo lo que use para hacer daño.

            if (enemyGray)
            {
                hitsRemaining--;
                if (hitsRemaining <= 0)
                {
                    _isDestroyed = true;
                    SetDamagedBaseballBat();
                    GameVars.Values.soundManager.PlaySoundAtPoint("RacketBroken", transform.position, 0.09f);
                    GameVars.Values.ShowNotification("Oh no! The Baseball Bat has broken!");
                    _player.BaseballBatInventoryRemoved();
                }
                other.GetComponent<Enemy>().TakeDamage(damageAmount);
                IsAttacking = false; //Lo dejo en falso para que no repita el daño, veremos.
            }
        }
    }*/
    public override void OnHitEffect()
    {
        if (IsAttacking)
        {
            Debug.Log("Hit WITH BASEBALL BAT TO GRAY?");
            hitsRemaining--;
            if (hitsRemaining <= 0)
            {
                _isDestroyed = true;
                SetDamagedBaseballBat();
                GameVars.Values.soundManager.PlaySoundAtPoint("RacketBroken", transform.position, 0.09f);
                GameVars.Values.ShowNotification("Oh no! The Baseball Bat has broken!");
                _player.BaseballBatInventoryRemoved();
            }
            IsAttacking = false; //Lo dejo en falso para que no repita el daño, veremos.
        }
    }
    public void DestroyAndRestoreValues()
    {
        this.gameObject.SetActive(false);

        hitsRemaining = 12; //Hacer un void ResetHits() despues.
        transform.localRotation = _startingRotation;
        transform.parent.parent = _player.Cam.transform;
        transform.parent.localPosition = Vector3.zero;
        transform.parent.localRotation = Quaternion.Euler(0f, 0f, 0f);
        anim.SetBool("IsDestroyed", false);
        _meshFilter.mesh = _newBaseballBatMesh;
    }
}
