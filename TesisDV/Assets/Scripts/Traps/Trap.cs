using System.Runtime.Versioning;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Linq;

public abstract class Trap : MonoBehaviour
{
    public bool active;
    protected bool _canShoot = false;
    protected Animator _animator;
    [SerializeField] protected GameObject UITrapIndicator;
    [SerializeField] protected Texture UITexture;

    [SerializeField] protected float viewRadius;
    [SerializeField] protected float viewAngle;
    [SerializeField] protected LayerMask targetMask;
    [SerializeField] protected LayerMask obstacleMask;

    [SerializeField] protected Transform myCannon;
    [SerializeField] protected Transform myCannonSupport;

    protected float _futureTime = 1f;
    protected float _shootSpeed = 5f;

    protected float _currentObjectiveDistance = 1000;
    protected Collider _currentObjective = null;
    public Collider[] collidersObjectives;
    protected Collider[] collidersObjectivesDisabled;
    protected const float MAX_CURRENT_OBJETIVE_DISTANCE = 1000;

    protected TrapBase _myTrapBase;

    public void FieldOfView()
    {
        Collider[] allTargets = Physics.OverlapSphere(transform.position, viewRadius, targetMask);

        collidersObjectives = allTargets.Where(x => x.GetComponent<Enemy>().isActiveAndEnabled).ToArray();

        collidersObjectivesDisabled = allTargets.Where(x => !x.GetComponent<Enemy>().isActiveAndEnabled).ToArray();

        if (allTargets.Length == 0 || _currentObjective == null)
        {
            _currentObjective = null;
            _canShoot = false;
            _currentObjectiveDistance = MAX_CURRENT_OBJETIVE_DISTANCE;
        }

        if (_currentObjective == null || _currentObjective.GetComponent<Enemy>().isDead || _currentObjectiveDistance > viewRadius)
        {
            foreach (var item in allTargets)
            {
                if (Vector3.Distance(transform.position, item.transform.position) < _currentObjectiveDistance)
                {
                    if (!item.GetComponent<Enemy>().isDead)
                    {
                        _currentObjectiveDistance = Vector3.Distance(transform.position, item.transform.position);
                        _currentObjective = item;

                        _animator.enabled = false;
                    }
                }
            }
        }

        if (_currentObjectiveDistance < viewRadius && _currentObjective != null)
        {
            //Vector3 futurePos = _currentObjective.transform.position + (_currentObjective.GetComponent<Enemy>().GetVelocity() * _futureTime * Time.deltaTime);
            //Claro, se fue el Navmesh y ahora tengo que ver como arreglar lo del velocity para poder dar la referencia.
            //Cuando esté todo hecho lo del navmesh se verá.

            //Vector3 dir = futurePos - transform.position; Esto hasta arreglar el velocity
            Vector3 dir = _currentObjective.transform.position - transform.position;
            _currentObjectiveDistance = Vector3.Distance(transform.position, _currentObjective.transform.position);
            if (!Physics.Raycast(transform.position, dir, out RaycastHit hit, dir.magnitude, obstacleMask))
            {
                _canShoot = true;
                Debug.Log("true");


                Quaternion lookRotation = Quaternion.LookRotation(dir);
                Vector3 rotation = lookRotation.eulerAngles;

                myCannonSupport.rotation = Quaternion.Lerp(myCannonSupport.rotation, Quaternion.Euler(0f, rotation.y, 0f), _shootSpeed * Time.deltaTime);

                myCannon.rotation = Quaternion.Lerp(myCannon.rotation, Quaternion.Euler(0f, rotation.y, rotation.z), _shootSpeed * Time.deltaTime);
                Debug.DrawLine(transform.position, _currentObjective.transform.position, Color.red);
                return;
            }
        }


        /* if (allTargets.Length == 0 && _currentObjective == null) Por ahora no usamos esto al no tener animaciones.
        {
            if (searchingForTargetCoroutine != null) StopCoroutine(searchingForTargetCoroutine);
            
            searchingForTargetCoroutine = StartCoroutine("RoutineSearchingForObjectives");
            laser.gameObject.SetActive(false);
        } */
    }
    protected void SetUIIndicator(string UIIndicatorName) 
    {
        UITexture = Resources.Load<Texture>(UIIndicatorName);
        UITrapIndicator = transform.GetComponentsInChildren<Transform>().FirstOrDefault(x => x.name.Equals("MiniMapIndicatorActive")).gameObject;
        UITrapIndicator.GetComponent<MeshRenderer>().material.SetTexture("_Placeholder", UITexture);
    }

    public virtual void Inactive()
    {

    }
}
